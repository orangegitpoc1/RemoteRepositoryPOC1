/**************************************************************
Created By:162487
Ust-1335
Cretaed on :2/8/2016
Test class  for class SMB_scheduled_Count_NO_of_Partner

***************************************************************/
@isTest
Private class SMB_scheduled_Count_NO_of_Partner_Test{
 static testmethod void test() {
   Test.startTest();

   // Schedule the test job 
      String jobId = System.schedule('testBasicScheduledApex',
      SMB_scheduled_Count_NO_of_Partner.CRON_EXP, 
         new SMB_scheduled_Count_NO_of_Partner ());
   // Get the information from the CronTrigger API object 
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

   // Verify the expressions are the same 
    
      System.assertEquals(SMB_scheduled_Count_NO_of_Partner.CRON_EXP, 
         ct.CronExpression);

   // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

   
      

   Test.stopTest();

   }
}