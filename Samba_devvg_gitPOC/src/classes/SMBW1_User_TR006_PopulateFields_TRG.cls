/*******************************************************
Created by J. Hazebrouck
Associated Business Requirement: BR-5
When account owner is changing it should be possible to auto-populate
a list of fields with information from the Account Owner profile:
Sales Region
Sales Cluster
Sales Country
Sales Territory
*******************************************************/
public without sharing class SMBW1_User_TR006_PopulateFields_TRG {

	/*public static void PopulateRegionFieldsInAccounts(List<User> listUser){
		//Get all accounts with account owner in the list
		List<Account> listAcc = [SELECT Id, OwnerId, Sales_Region__c, Sales_Cluster__c, Sales_Country__c,
		Sales_Territory__c FROM Account WHERE OwnerId IN: listUser];
		List<Account> listAccToUpdate = new List<Account>();
		
		//replace region, cluster, country and territory in all accounts from account owners
		for(User u : listUser){
			for(Account a : listAcc){
				if(a.OwnerId == u.Id){
					a.Sales_Region__c = u.SMB_Sales_Region__c;
					a.Sales_Cluster__c = u.SMB_Sales_Cluster__c;
					a.Sales_Country__c = u.SMB_Sales_Country__c;
					a.Sales_Territory__c = u.SMB_Sales_Territory__c;
					listAccToUpdate.add(a);
				}
			}
		}
		update listAccToUpdate;
	}*/
}