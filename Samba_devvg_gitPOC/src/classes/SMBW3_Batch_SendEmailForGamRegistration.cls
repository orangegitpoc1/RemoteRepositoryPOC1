global class SMBW3_Batch_SendEmailForGamRegistration implements Database.Batchable<sObject>{
   
    global final String query;
    global final String frequencyType;

    global SMBW3_Batch_SendEmailForGamRegistration(String q, String f){
        Query=q;
        frequencyType=f;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //DateTime pastDateTime = DateTime.now().addMinutes(-10);
        //return Database.getQueryLocator('SELECT Id, Name, GAM_type__c, Owner.Name, Account.Name, RecordType.Name, StageName, Amount FROM Opportunity WHERE GAM_type__c = \'Standard GAM\' AND CurrentDateTime_OnChange_Of_Registration__c >:pastDateTime AND Standard_GAM_Registered__c=true');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String relativeUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Set<Id> oppIdsForGamReg = new Set<Id>();
        String contentForGamReg = System.Label.SMBW3_CL0014_contentForGamReg;
        String bodyForGamReg = '<table border=1 width=50%><tr><th>'+System.Label.SMBW3_CL0011_Name+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0013_Opp_Owner+'</th><th>'+System.Label.SMBW3_CL0034_AccountName+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0035_RecordType+'</th><th>'+System.Label.SMBW3_CL0036_Stage+'</th>'+
                                '<th>'+System.Label.SMBW3_CL0036_Amount+'</th></tr>';        
       
        for(Opportunity opp : (List<Opportunity>)scope){
            oppIdsForGamReg.add(opp.Id);
            bodyForGamReg+='<tr><td><a href='+relativeUrl+'/'+opp.Id+'>'+opp.Name+'</a></td><td>'+opp.Owner.Name+'</td>'+
                            '<td>'+opp.Account.Name+'</td><td>'+opp.RecordType.Name+'</td><td>'+opp.StageName+'</td><td>'+
                            opp.Amount+'</td></tr>';
        }
        bodyForGamReg+='</table>';

        if(oppIdsForGamReg.size()>0){
            SMBW3_EmailToOppTeamMembers.sendEmail(oppIdsForGamReg, contentForGamReg+bodyForGamReg, frequencyType);
        }
        
    }

    global void finish(Database.BatchableContext BC){
        
    }
}