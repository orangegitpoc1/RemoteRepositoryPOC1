global class SMBW3_SchedulerOf1DayForGAMRegistration implements Schedulable {
   global void execute(SchedulableContext SC) {

      Database.executebatch(new SMBW3_Batch_SendEmailForGamRegistration
      ('SELECT Id, Name, GAM_type__c, Owner.Name, Account.Name, RecordType.Name, StageName, Amount FROM Opportunity WHERE GAM_type__c = \'Standard GAM\' '+
      'AND CurrentDateTime_OnChange_Of_Registration__c = LAST_N_DAYS:1 AND Standard_GAM_Registered__c=true', 
      System.Label.User_Frequency_1day));

   }
}