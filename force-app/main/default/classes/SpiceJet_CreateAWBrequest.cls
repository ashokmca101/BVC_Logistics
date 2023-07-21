public with sharing class SpiceJet_CreateAWBrequest {
   // wrapper class is used in spicejet AWB request. 
    public String awb_number; //null
    public String origin;	//DEL
    public String destination;	//BLR
    public String customer;
    public String commodity_code;	//GEN
    public String commodity_description;	//GENERAL
    public String total_pieces;	//1
    public cls_Shipper shipper;
    public cls_Consignee consignee;
    public String gross_weight;	//100
    public cls_products[] products;
    public cls_flight_route[] flight_route;
    public String mode;	//BVC
        
    
    public class cls_products {
        public String height_dimension;
        public String length_dimension;
        public String width_dimension;
        public String requested_quantity;	//1
        public String weight_dimension;	//100
        public String bag_number;	//1
        public String dimension_type;	//CMS
        public String type;	//KG
    }
    
    public class cls_flight_route {
        public String route_type;	//air
        public String partner_type;
        public String partner_code;
        public String flight_destination;	//BLR
        public String flight_origin;	//DEL
        public String tofrom;	//2022-07-22 20:00:00
        public String flight_code;	//SG537
        //public String id;
    }
public class cls_Shipper{
    public String shipper_address;
    public String shipper_name;
    public String shipper_city;
    public String shipper_state_code;
    public String shipper_country_code;
    public String shipper_postal_code;
    public String shipper_contact_number;
    public String shipper_email;
    
    }  
    
    public class cls_Consignee{
    public String consignee_address;
    public String consignee_name;
    public String consignee_city;
    public String consignee_state_code;
    public String consignee_country_code;
    public String consignee_postal_code;
    public String consignee_contact_number;
    public String consignee_email; 
    }
      
}