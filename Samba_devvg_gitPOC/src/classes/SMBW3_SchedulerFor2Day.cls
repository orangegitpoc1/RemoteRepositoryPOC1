global class SMBW3_SchedulerFor2Day implements Schedulable {
   global void execute(SchedulableContext SC) {
      //mergeNumbers M = new mergeNumbers();
      Database.executebatch(new SMBW3_Batch_SendEmailForDiffGamType('SELECT Id, Name, GAM_type__c,  Owner.Name, Account.Name, RecordType.Name, StageName, Amount FROM Opportunity WHERE '+ 
      '(GAM_type__c = \'Territory Model\' OR GAM_type__c = \'Standard GAM\') AND (LastModifiedDate= LAST_N_DAYS:2 OR CreatedDate=LAST_N_DAYS:2)', 
      System.Label.User_Frequency_2days));
   }
}