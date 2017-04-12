/**************************************************************
Created By:162487
Ust-1335
Cretaed on :2/8/2016
Schedule class to run batch class SMB_Count_NO_of_Partner_Opportunity

***************************************************************/
global class SMB_scheduled_Count_NO_of_Partner implements Schedulable {
 public static String CRON_EXP = '0 58 * * * ?';             // cron exp to be use in Test class
   
   global void execute(SchedulableContext sc) {              // execute schedule job 
      
      /***********************call batch class ********************************************/
       SMB_Count_NO_of_Partner_Opportunity b = new SMB_Count_NO_of_Partner_Opportunity('SELECT id,Partner_Is_available__c,Smb_opportunity_without_partner__c,SMB_OPP_stage_Gam_nb__c FROM Opportunity'); 
       if(!Test.isRunningTest()){                             // not to run in test class                                    
           database.executebatch(b,200);
       }
   }
}