global class SMB_BatchActionPlanOnTrigger_Share implements Database.Batchable<sObject>{

   global String Query;
   set<id> apid=new set<id>();
   
    global SMB_BatchActionPlanOnTrigger_Share (list<Action_Plan__c> actionp){
     For(Action_Plan__c Ap : actionp){
       apid.add(Ap.id);
     }
    
    }

   global Database.QueryLocator start(Database.BatchableContext BC){
     // Query='SELECT CreatedDate,Id,LastModifiedDate,Name,OwnerId,SMB_AP_Account__c,SMB_AP_IsActive__c FROM Action_Plan__c';
      return Database.getQueryLocator([SELECT Id,Name,OwnerId,SMB_AP_Account__c,SMB_AP_IsActive__c FROM Action_Plan__c where id In:apid]);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       system.debug('scope'+scope);
       
       SMB_BatchActionPlan.Exceutebatch(scope,false);
         
     
    }

   global void finish(Database.BatchableContext BC){
   }
}