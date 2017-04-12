global class SMB_BatchActionPlan_Share implements Database.Batchable<sObject>{

   global String Query;
    

   global Database.QueryLocator start(Database.BatchableContext BC){
      Query='SELECT CreatedDate,Id,LastModifiedDate,Name,OwnerId,SMB_AP_Account__c,SMB_AP_IsActive__c FROM Action_Plan__c';
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       system.debug('scope'+scope);
       
       SMB_BatchActionPlan.Exceutebatch(scope,true);
         
     
    }

   global void finish(Database.BatchableContext BC){
   }
}