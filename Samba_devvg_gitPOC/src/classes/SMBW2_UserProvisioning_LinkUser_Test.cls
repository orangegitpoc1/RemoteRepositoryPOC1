@isTest(SeeAllData=true)
private class SMBW2_UserProvisioning_LinkUser_Test {

	static testMethod void myUnitTest(){
		String profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
      	User u = new User(alias = 'standt', email='test@test.net', localesidkey='en_US', profileid = profId,
		timezonesidkey='America/Los_Angeles', username='test@devTest.com.test', CommunityNickname = 'test@devTest.com.test',
		languagelocalekey='en_US', FirstName = 'toto', LastName = 'Test', emailencodingkey='UTF-8');
		insert u;
		
		User_Provisioning__c up = new User_Provisioning__c(Name='test@devTest.com.test');
		insert up;
		
		Test.startTest();
		ApexPages.StandardController scTest = new ApexPages.standardController(up);
		SMBW2_UserProvisioning_LinkUser_VFC upTest = new SMBW2_UserProvisioning_LinkUser_VFC(scTest);
		upTest.init();
		upTest.cancel();
		Test.stopTest();
	}
}