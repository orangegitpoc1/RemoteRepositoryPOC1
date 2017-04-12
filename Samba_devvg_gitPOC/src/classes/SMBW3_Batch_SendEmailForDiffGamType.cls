global class SMBW3_Batch_SendEmailForDiffGamType implements Database.Batchable<sObject>{
   
    global final String query;
    global final String frequencyType;

    global SMBW3_Batch_SendEmailForDiffGamType(String q, String f){
        Query=q;
        frequencyType=f;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //DateTime pastDateTime = DateTime.now().addMinutes(-10);
        //return Database.getQueryLocator('SELECT Id, Name, GAM_type__c, Owner.Name, Account.Name, RecordType.Name, StageName, Amount FROM Opportunity WHERE (GAM_type__c = \'Territory Model\' OR GAM_type__c = \'Standard GAM\') AND (LastModifiedDate >: pastDateTime OR CreatedDate>: pastDateTime)');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String relativeUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Set<Id> oppIdsForGam = new Set<Id>();
        String contentForGam = System.Label.SMBW3_CL0010_contentForGam;
        String bodyForGam = '<table border=1 width=50%><tr><th>'+System.Label.SMBW3_CL0011_Name+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0013_Opp_Owner+'</th><th>'+System.Label.SMBW3_CL0034_AccountName+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0035_RecordType+'</th><th>'+System.Label.SMBW3_CL0036_Stage+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0036_Amount+'</th></tr>';        

        Set<Id> oppIdsForModel = new Set<Id>();
        String contentForModel = System.Label.SMBW3_CL0012_contentForModel;
        String bodyForModel = '<table border=1 width=50%><tr><th>'+System.Label.SMBW3_CL0011_Name+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0013_Opp_Owner+'</th><th>'+System.Label.SMBW3_CL0034_AccountName+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0035_RecordType+'</th><th>'+System.Label.SMBW3_CL0036_Stage+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0036_Amount+'</th></tr>';
        
                
        for(Opportunity opp : (List<Opportunity>)scope){
            if(opp.GAM_type__c == 'Standard GAM'){
                oppIdsForGam.add(opp.Id);
                bodyForGam+='<tr><td><a href='+relativeUrl+'/'+opp.Id+'>'+opp.Name+'</a></td><td>'+opp.Owner.Name+'</td>'+
                            '<td>'+opp.Account.Name+'</td><td>'+opp.RecordType.Name+'</td><td>'+opp.StageName+'</td><td>'+
                            opp.Amount+'</td></tr>';
            }else{
                oppIdsForModel.add(opp.Id);
                bodyForModel+='<tr><td><a href='+relativeUrl+'/'+opp.Id+'>'+opp.Name+'</a></td><td>'+opp.Owner.Name+'</td>'+
                                '<td>'+opp.Account.Name+'</td><td>'+opp.RecordType.Name+'</td><td>'+opp.StageName+'</td><td>'+
                                opp.Amount+'</td></tr>';                
            }
        }
        bodyForGam+='</table>';
        bodyForModel+='</table>';

        if(oppIdsForGam.size()>0){
            SMBW3_EmailToOppTeamMembers.sendEmail(oppIdsForGam, contentForGam+bodyForGam, frequencyType);
        }
        if(oppIdsForModel.size()>0){
            SMBW3_EmailToOppTeamMembers.sendEmail(oppIdsForModel, contentForModel+bodyForModel, frequencyType);
        } 
        
    }

    global void finish(Database.BatchableContext BC){
        
    }
}