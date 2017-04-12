public with sharing class SMBW3_AccountExt {
    
    public Attachment insertedAttach{get;set;}
    public List<Attachment> approvalAttachments{get;set;}
    public List<Attachment> nonApprovalAttachments{get;set;}
    
    public List<Note> getNotes(){
        Set<Id> noteIds = new Set<Id>(); 
        for(Opportunity opp : [SELECT Id, (SELECT Id FROM Notes) FROM Opportunity WHERE 
                                AccountId =: ApexPages.currentPage().getParameters().get('id') ])
        {
            for(Note nt : opp.Notes){
                noteIds.add(nt.Id);
            }
        }
        return [SELECT Id, Title, ParentId, Parent.Name, LastModifiedDate, CreatedById FROM Note WHERE 
                ParentId =: ApexPages.currentPage().getParameters().get('id') OR Id IN : noteIds ORDER BY LastModifiedDate DESC];
    }
    
    public SMBW3_AccountExt(ApexPages.StandardController controller) {
        Set<Id> setOfAllOppAttachIds = new Set<Id>();
        for(Opportunity opp : [SELECT Id, (SELECT Id FROM Attachments) FROM Opportunity WHERE 
                                AccountId =: ApexPages.currentPage().getParameters().get('id')])
        {
            for(Attachment a : opp.Attachments){
                setOfAllOppAttachIds.add(a.Id);
            }
        }
        Set<Id> attachAssocToMastApprov = new Set<Id>();
        for(Master_Attachment_Approval__c maa : [SELECT Approve__c, Reject__c, Attachment_id__c FROM Master_Attachment_Approval__c 
                                                    WHERE Attachment_id__c IN : setOfAllOppAttachIds])
        {
            attachAssocToMastApprov.add(maa.Attachment_id__c);
            setOfAllOppAttachIds.remove(maa.Attachment_id__c);
        }
        
        approvalAttachments = new List<Attachment>([SELECT Id, Name, ParentId, Parent.Name, LastModifiedDate, CreatedById 
                                            FROM Attachment WHERE
                                            Id IN : attachAssocToMastApprov ORDER BY LastModifiedDate DESC]);
        
        nonApprovalAttachments = new List<Attachment>([SELECT Id, Name, ParentId, Parent.Name, LastModifiedDate, CreatedById 
                                            FROM Attachment WHERE
                                            ParentId =: ApexPages.currentPage().getParameters().get('id') OR
                                            Id IN : setOfAllOppAttachIds ORDER BY LastModifiedDate DESC]);                                          

    }
    
    public String delId{get;set;}
    public void delAttachAndNote(){
        UserRecordAccess ura=[SELECT RecordId, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :delId];
        if (ura.HasDeleteAccess) {
            try{
                Database.delete(delId);
            }catch(DmlException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDMLMessage(0)));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You do not have permission to delete this Record.'));
        }
    }
    
    public PageReference navigateBack(){
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }

    public Attachment myfile;
    public Attachment getMyFile(){
        myfile = new Attachment();
        return myfile;
    }
   
    public PageReference saveDoc(){
        Attachment a = new Attachment
        (parentId = ApexPages.currentPage().getParameters().get('id'), name=myfile.name, body = myfile.body);
        insert a;
        
        insertedAttach = [SELECT Name, BodyLength FROM Attachment WHERE Id =: a.Id];        
        myfile.body=null;
        
        return ApexPages.currentPage();        
    }   

}