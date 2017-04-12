global class SMBW3_Batch_Temp_Data_Fix_MustWinLevel implements Database.Batchable<sObject> {

global final String query='select id, name, StageName, SMB_Opp_Must_Win__c, SMB_OPP_Must_Win_level__c from Opportunity where (NOT StageName LIKE \'Closed%\')';
// and SMB_Opp_Must_Win__c=\'No\'
//List<Opportunity> opps=[select id, name, StageName, SMB_Opp_Must_Win__c, SMB_OPP_Must_Win_level__c from Opportunity where (NOT StageName LIKE :'Closed%') and SMB_Opp_Must_Win__c=:'No'];

global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
}

 global void execute(Database.BatchableContext BC, List<Opportunity> opps){
        
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    for (Opportunity oppty: opps) {
        if(
              oppty.SMB_Opp_Must_Win__c=='No' || oppty.SMB_Opp_Must_Win__c==null || 
              (oppty.SMB_Opp_Must_Win__c=='Yes' && oppty.SMB_OPP_Must_Win_level__c==null)
          ) {
            oppty.SMB_OPP_Must_Win_level__c='None';
            oppsToUpdate.add(oppty);
        }
        
    }
    update oppsToUpdate;
    System.debug('Records Updated:'+oppsToUpdate.size());
 }
 
 
  global void finish(Database.BatchableContext BC){
        
  }
}