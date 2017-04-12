public without sharing class SMBW2_UserProvisioning_LinkUser_VFC {

	private String uId;
	public User_Provisioning__c up = new User_Provisioning__c();
	
	public SMBW2_UserProvisioning_LinkUser_VFC(ApexPages.StandardController controller){
		this.uId = controller.getRecord().Id;
		up = [SELECT Id, Name, Salesforce_User__c FROM User_Provisioning__c WHERE Id =: uId LIMIT 1];
	}
	
	public pageReference init(){
		List<User> listU = [SELECT Id FROM User WHERE UserName =: up.Name limit 1];
		if(listU.size() > 0){
			up.Salesforce_User__c = listU[0].Id;
			update up;
		}
		pageReference pageRef = new pageReference('/' + uId);
		return pageRef;
	}
	
	public pageReference cancel(){
    	pageReference pageRef = new pageReference('/' + uId);
		return pageRef;
    }
}