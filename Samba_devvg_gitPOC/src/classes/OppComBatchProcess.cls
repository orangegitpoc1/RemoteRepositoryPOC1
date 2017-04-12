global class OppComBatchProcess implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT CurrencyIsoCode, Name, Opportunity__c, ';
        query += ' SMB_OPCOM_Competitor_Name__c, SMB_OPCOM_Primary__c, SMB_OPCOM_Strengths__c, ';
        query += ' SMB_OPCOM_Weaknesses__c, SMB_Standard_Competitor_Id__c  FROM Competitor__c'; 
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Competitor__c> scope){
        
        List<Competitor__c> comList = new List<Competitor__c>();
        for(Competitor__c com : scope){
            OpportunityCompetitor comp = new OpportunityCompetitor(); 
            
            if (com.SMB_OPCOM_Competitor_Name__c.length() > 40) { 
                comp.CompetitorName = com.SMB_OPCOM_Competitor_Name__c.substring(1, 39); 
            }else{ 
                comp.CompetitorName = com.SMB_OPCOM_Competitor_Name__c; 
            } 
            comp.Strengths = com.SMB_OPCOM_Strengths__c; 
            comp.Weaknesses = com.SMB_OPCOM_Weaknesses__c; 
            comp.OpportunityId = com.Opportunity__c;
            insert comp;
            system.debug('-----insertSuccessful----' + comp);
            com.SMB_Standard_Competitor_Id__c = comp.Id;
            comList.add(com);
        }
        update comList;
        
    }

    global void finish(Database.BatchableContext BC){
 
    }


}