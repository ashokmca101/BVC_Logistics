global class BVC_SSO implements Auth.RegistrationHandler {
 global User createUser(Id portalId, Auth.UserData data){
        
        String dataEmail = '%'+data.email+'%';
        User u = [SELECT Id, username, email, lastname, firstname, alias, languagelocalekey,
                  localesidkey, emailEncodingKey, timeZoneSidKey, profileId
                  from user where username LIKE :dataEmail and IsActive = true limit 1 
                 ];
        
        System.debug('@@ User Login SSO google @@'+u);
        System.debug('@@ User Login SSO google Data@@'+data);
        user ur = new user();
        if(u != NULL){
             ur = u;
        }
        return ur;
    }
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    /*    
        User u = new User(id=userId);
        //TODO: Customize the username. Must be 80 characters or less.
        u.username = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        
        
        String alias = data.username;
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        
        update u;*/
    }
}