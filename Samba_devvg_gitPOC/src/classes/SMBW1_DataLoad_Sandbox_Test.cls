@isTest(SeeAllData=true)
public class SMBW1_DataLoad_Sandbox_Test {
	static testMethod void myUnitTest(){
		List<StaticResource> listResource = [SELECT Id, Name FROM StaticResource WHERE Name =: 'object_csv' limit 1];
		
		Test.startTest();
		SMBW1_DataLoad_Sandbox testDataLoad = new SMBW1_DataLoad_Sandbox();
		SMBW1_DataLoad_Sandbox testDataLoad1 = new SMBW1_DataLoad_Sandbox(listResource[0].Name);
		testDataLoad1.parseCsv();
		Test.stopTest();
	}
}