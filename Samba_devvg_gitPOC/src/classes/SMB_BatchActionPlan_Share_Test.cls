@isTest
public class SMB_BatchActionPlan_Share_Test{
  public static String CRON_EXP = '0 0 0 15 3 ? 2022';


    public static testMethod void testBatch() {
    SMB_BatchActionPlan_Share SBPS=new SMB_BatchActionPlan_Share();
     list<account> ac=TestDataCreation.createAccounts(1);
     System.assertEquals(1,ac.size());
     list<User> listUser=TestDataCreation.createUsersWithUsernamePrefixAlias(5,'System Administrator','5',null,'test','ts');
     List<Account> Listacc=TestDataCreation.createultimateAccounts(3,ac[0].id);
     System.assertEquals(3,Listacc.size());
     List<Action_Plan__c> listActionPlan=TestDataCreation.CreateActionPlan(10,ac[0].id);
     System.assertEquals(10,listActionPlan.size());
     TestDataCreation.CreateAccountTeamMember(ac[0].id,listUser);
     Test.StartTest();
     SMB_BatchActionPlanOnTrigger_Share SBATS= new SMB_BatchActionPlanOnTrigger_Share (listActionPlan);
     ID batchprocessid = Database.executeBatch(SBPS);
     Test.StopTest();

    }
    
    
   static testmethod void testScheduler() {
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('SMB_BatchActionPlan_SchedulerTest',
                        CRON_EXP, 
                        new SMB_BatchActionPlan_Scheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
     
      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(),
      //   fetch the new merchandise that got added.
      

   }

}