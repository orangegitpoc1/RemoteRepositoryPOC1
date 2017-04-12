@isTest
public class SMBW3_Batch_Temp_Data_Fix_MustWinLTest{

    static testMethod void testSchedule(){
		
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
			
			ID jobId = Database.executeBatch(new SMBW3_Batch_Temp_Data_Fix_MustWinLevel(),25);

    }
    
}