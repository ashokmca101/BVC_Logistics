({
	navigateToLoginPage : function(component, navigationService) {

        var actionName = component.get("v.actionName"); // Options supported are 'login' or 'logout' .

        var pageReference = {

            type: 'comm__loginPage',

            attributes: {

                actionName: 'logout' 

            }

        };
        navigationService.navigate(pageReference);
    }
})