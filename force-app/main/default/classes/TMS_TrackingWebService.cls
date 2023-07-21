@RestResource(urlMapping='/ShipmentTracking/*')
global without sharing class TMS_TrackingWebService {
    @HttpGet
    global static Map<String,List<TrackingInfo>> getTrackingById() {
        system.debug('called');
        RestRequest request = RestContext.request; 
        // grab the trackingId from the end of the URL
        String trackingId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        if(string.isNotBlank(trackingId)){
            List<String> SNNs = trackingId.split(','); 
            System.debug('trackingId====='+trackingId);
            List<Shipment_Tracking__c> resultList =  [SELECT Shipment__c, Location__c,Scan_Time__c,Shipment__r.Shipping_Note_Number__c,Shipment__r.Delivered_To_Person__c,Shipment__r.Actual_Delivery_Date_and_Time__c
                                                      ,City__c , Shipment__r.Estimated_Delivery_Date__c FROM Shipment_Tracking__c
                                                      WHERE Shipment__r.Shipping_Note_Number__c = :SNNs ORDER BY Scan_Time__c  LIMIT 50000];
            
            Set<id> Track_shipId_Set = new Set<id>();
            Map<String,List<TrackingInfo>> TrackingInfoMap = new Map<String,List<TrackingInfo>>();
            if(resultList != null && resultList.size()>0){
                
                for(Shipment_Tracking__c st:resultList){
                    if(st.Location__c=='Delivered'){
                        system.debug('ship:'+st.Shipment__c);
                        Track_shipId_Set.add(st.Shipment__c);
                    }
                }
                Map<id,List<id>> Ship_DocId_Map = new Map<id,List<id>>();
                Map<id,List<string>> Ship_File_Map = new Map<id,List<string>>();
                Map<id,string> Pod_File_Map = new Map<id,string>();
                Set<Id> idSetquery = new Set<Id>();
                
                if(Track_shipId_Set != null && Track_shipId_Set.size()>0){
                    system.debug('set: '+Track_shipId_Set);
                    List<ContentDocumentLink> files = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :Track_shipId_Set];
                    for(ContentDocumentLink file :files){
                        if(!Ship_DocId_Map.containsKey(file.LinkedEntityId)){
                            Ship_DocId_Map.put(file.LinkedEntityId, new List<Id>{});              
                        }
                        
                        idSetquery.add(file.ContentDocumentId);
                        Ship_DocId_Map.get(file.LinkedEntityId).add(file.ContentDocumentId);
                        
                    }
                    
                    
                    
                    List<ContentVersion> cvlst = [SELECT Title, VersionData,ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId = :(idSetquery)  AND Title LIKE '%Signature%' ORDER BY CreatedDate DESC LIMIT 1];
                    
                    Set<Id> contentDocIdsSign = new Set<Id>();
                    
                    for(ContentVersion cv:cvlst){
                        system.debug('title: '+cv.Title);
                        contentDocIdsSign.add(cv.ContentDocumentId);
                        /*if(!Ship_File_Map.containsKey(cv.ContentDocumentId)){
                            Ship_File_Map.put(cv.ContentDocumentId, new List<String>{});              
                        }
                        Ship_File_Map.get(cv.ContentDocumentId).add(EncodingUtil.base64Encode(cv.VersionData));
                        system.debug('Ship_File_Map at 50'+Ship_File_Map.size());*/
                       
                    }
                    
                    List<ContentDistribution> conDistListSign = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN : contentDocIdsSign];
                    
                    for(ContentDistribution cds:conDistListSign){
                        if(!Ship_File_Map.containsKey(cds.ContentDocumentId)){
                            Ship_File_Map.put(cds.ContentDocumentId, new List<String>{});              
                        }
                        Ship_File_Map.get(cds.ContentDocumentId).add(cds.DistributionPublicUrl);
                    }
                    
                    
                    Set<id> contentDocIds = new Set<id>();
                    List<ContentDocumentLink> podDocumentlst = [SELECT Id, LinkedEntityId, ContentDocument.LatestPublishedVersion.VersionData, 
                                                           ContentDocument.LatestPublishedVersion.Id, ContentDocument.LatestPublishedVersion.Title,ContentDocumentId, 
                                                           ContentDocument.LatestPublishedVersion.ContentSize, SystemModstamp 
                                                           FROM ContentDocumentLink 
                                                           WHERE  LinkedEntityId IN :Track_shipId_Set AND 
                                                           (NOT ContentDocument.LatestPublishedVersion.Title Like'%Signature%')  
                                                           ORDER BY SystemModstamp DESC];
                   /*for(ContentDocumentLink podDocument:podDocumentlst){
                      
                                                  Pod_File_Map.put(podDocument.ContentDocumentId, EncodingUtil.base64Encode(podDocument.ContentDocument.LatestPublishedVersion.VersionData));

                    }*/
                    
                   //--- Added by Dipak - 02/09/2022
                   
                   for(ContentDocumentLink podDocument:podDocumentlst){
                        
						contentDocIds.add(podDocument.ContentDocumentId);
                        //Pod_File_Map.put(podDocument.ContentDocumentId, EncodingUtil.base64Encode(podDocument.ContentDocument.LatestPublishedVersion.VersionData));
                    }
					
					
					List<ContentDistribution> conDistList = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN : contentDocIds];
					
					for(ContentDistribution cd : conDistList){
						Pod_File_Map.put(cd.ContentDocumentId, cd.DistributionPublicUrl);
					}
                 
                }
                
                for(Shipment_Tracking__c st:resultList){
                    TrackingInfo info = new TrackingInfo();
                    info.City=st.City__c;
                    info.Location = st.Location__c;
                    info.DeliveryInformation.ActualDeliveryTime='';
                    info.DeliveryInformation.DeliveredTo = '';
                    info.DeliveryInformation.Signature = '';
                    
                    if(st.Location__c=='Delivered'){                    
                        if(st.Shipment__r.Actual_Delivery_Date_and_Time__c!=null)
                            info.DeliveryInformation.ActualDeliveryTime=st.Shipment__r.Actual_Delivery_Date_and_Time__c.format();
                        if(st.Shipment__r.Delivered_To_Person__c != null)
                            info.DeliveryInformation.DeliveredTo = st.Shipment__r.Delivered_To_Person__c;
                        Boolean docIdfound = false;
                        List<String> idDocString = new List<String>();
                        if(Ship_DocId_Map.get(st.Shipment__c)!=null && Ship_DocId_Map.containsKey(st.Shipment__c)){
                          for(Id idDoc: Ship_DocId_Map.get(st.Shipment__c)){
                            
                            if(Ship_File_Map.containsKey(idDoc)){
                                
                                docIdfound = true;
                                idDocString = Ship_File_Map.get(idDoc);
                                break;
                            }
                        }  
                        }
                        
                        if(Track_shipId_Set.contains(st.Shipment__c) && Pod_File_Map!=null && Pod_File_Map.size()> 0)
                        {
                         info.DeliveryInformation.PodImage=(Pod_File_Map.values());
                         
                        }
                        
                        if(Track_shipId_Set.contains(st.Shipment__c) && Ship_DocId_Map.get(st.Shipment__c)!=null && Ship_DocId_Map.containsKey(st.Shipment__c) && docIdfound==true){
                            info.DeliveryInformation.Signature = string.valueof(idDocString);//Ship_File_Map.get(Ship_DocId_Map.get(st.Shipment__c));
                        }
                        
                        
                    }else{
                        info.DeliveryInformation = null;
                    }
                    
                    if(st.Scan_Time__c !=null)
                        info.Scantime = st.Scan_Time__c.format();
                    
                    if(st.Shipment__r.Estimated_Delivery_Date__c !=null)
                        info.EstimatedDeliveryDate = st.Shipment__r.Estimated_Delivery_Date__c.format();
                    
                    if(TrackingInfoMap.containsKey(st.Shipment__r.Shipping_Note_Number__c)){
                        TrackingInfoMap.get(st.Shipment__r.Shipping_Note_Number__c).add(info);
                    }else{
                        TrackingInfoMap.put(st.Shipment__r.Shipping_Note_Number__c,new List<TrackingInfo>{info});
                    }
                }
            }
            System.debug(Limits.getHeapSize());
            return TrackingInfoMap;
        }
        return null;
    }
    global class TrackingInfo{
        global string Scantime;
        global string Location;
        global string City;
        global String EstimatedDeliveryDate;
        global DeliveryInfo DeliveryInformation = new DeliveryInfo();
    }
    
    global class DeliveryInfo{
        global string ActualDeliveryTime;
        global string DeliveredTo;
        global string Signature;
        global List<String> PodImage;
    }
}