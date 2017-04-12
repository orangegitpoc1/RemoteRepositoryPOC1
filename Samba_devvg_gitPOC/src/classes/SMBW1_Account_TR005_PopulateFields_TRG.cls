/*******************************************************
Created by J. Hazebrouck
Associated Business Requirement: BR-5
When creating and updating new accounts it should be possible to auto-populate
a list of fields with information from the Account Owner profile:
Sales Region
Sales Cluster
Sales Country
Sales Territory
*******************************************************/
public without sharing class SMBW1_Account_TR005_PopulateFields_TRG {

	/*public static void PopulateRegionFieldsFromUser(Map<Account, Id> mapAccWithOwner){
		//Get the Sales region, cluster and country infos from User
		List<User> listUser = [SELECT Id, SMB_Sales_Cluster__c, SMB_Sales_Country__c,
		SMB_Sales_Region__c, SMB_Sales_Territory__c FROM User WHERE Id IN: mapAccWithOwner.values()];
		
		for(Account a : mapAccWithOwner.keySet()){
			for(User u : listUser){
				if(u.Id == mapAccWithOwner.get(a)){
					a.Sales_Region__c = u.SMB_Sales_Region__c;
					a.Sales_Cluster__c = u.SMB_Sales_Cluster__c;
					a.Sales_Country__c = u.SMB_Sales_Country__c;
					a.Sales_Territory__c = u.SMB_Sales_Territory__c;
				}
			}
		}
	}*/
}