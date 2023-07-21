({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
       
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var Mobile = component.find("mobilephone").get("v.value");
        var panofentity = component.find("panofentity").get("v.value");
        var nameasperpan = component.find("nameofentity").get("v.value");
        
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        
         if(this.validateNullFields(component, event, helpler)){
            return null;
        }
        console.log("FirstName"+firstname);
        console.log("LastName"+lastname);
        console.log("Email"+email);
        console.log("Mobile"+Mobile);
        console.log("Pan number"+panofentity);
        console.log("Name as per pan"+nameasperpan);
       
        //invoke check duplicate contact/user
        if(this.checkDuplicateContact(component, event, helpler)){
        	return Null; 
        }
        
        //invoke register controller method.
        action.setParams({firstname:firstname,lastname:lastname,email:email,
                          mobilephone:Mobile,nameasperpan:nameasperpan,panofentity:panofentity,
                password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, extraFields:extraFields, startUrl:startUrl, includePassword:includePassword});
          action.setCallback(this, function(a){
              var state = a.getState();
             var rtnValue = a.getReturnValue();  
              if( state=== 'SUCCESS'){
                   if (rtnValue !== null) {
                     component.set("v.errorMessage",rtnValue);
                     component.set("v.showError",true);
                   }
              } else{
                  component.set("v.errorMessage",'Internal error occured, please contact at care@bvclogistics.com.');
                  component.set("v.showError",true);
              }  
         
          
       });
    $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },
    checkDuplicateContact: function(component, event, helpler){
       //call apex method
       console.log("checkDuplicateContact method is called");
       var Email = component.find("email").get("v.value");
       var action = component.get("c.validateNewCustomer");
        console.log(Email);
        action.setParams({email: Email});
        action.setCallback(this, function(a){
            console.log('return val'+a.getReturnValue());
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null && rtnValue !='') {
               console.log('inside checkDuplicateContact if'+rtnValue);
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
               return True;
                //component.set('v.extraFields',rtnValue);
            }
            else{
                console.log('inside checkDuplicateContact else'+rtnValue);
                return False;
            }
        });
        $A.enqueueAction(action);
    },
    validateNullFields: function(component, event, helpler){
         var isError = false;
        if(component.find("firstname").get("v.value") =='' || component.find("firstname").get("v.value") == null){
            component.find("firstname").set("v.errors", [{message:"Complete this field."}]);
            isError =  true;
        }else{
            console.log('inside else of firstname');
            component.find("firstname").set("v.errors", [{message:null}]);
        }
        if(component.find("email").get("v.value") =='' || component.find("email").get("v.value") == null){
            component.find("email").set("v.errors", [{message:"Complete this field."}]);
            isError =  true;
        }else{
            component.find("email").set("v.errors", [{message:null}]);
        }
         if(component.find("lastname").get("v.value") =='' || component.find("lastname").get("v.value") == null){
            component.find("lastname").set("v.errors", [{message:"Complete this field."}]);
            isError =  true;
        }else{
            component.find("lastname").set("v.errors", [{message:null}]);
        }
        if(component.find("mobilephone").get("v.value").length != 10){
            component.find("mobilephone").set("v.errors", [{message:"Enter a 10 digit Mobile Number."}]);
            isError = true;
        }
        else{
            component.find("mobilephone").set("v.errors", [{message:null}]);
        }
        
        if(component.find("panofentity").get("v.value") == '' || component.find("panofentity").get("v.value") == null){
            component.find("panofentity").set("v.errors", [{message:"Enter a valid PAN Number"}]);
            isError = true;
        }
        else{
            component.find('panofentity').set("v.errors", [{message:null}]);
        }
        console.log('nameofentity:::'+component.find("nameofentity").get("v.value"));
        if(component.find("nameofentity").get("v.value") == '' || component.find("nameofentity").get("v.value") == null){
            component.find("nameofentity").set("v.errors", [{message:"Enter the Name of Entity"}]);
            isError = true;
        }
        else{
            component.find('nameofentity').set("v.errors", [{message:null}]);
        }
     return   isError;
   }
})