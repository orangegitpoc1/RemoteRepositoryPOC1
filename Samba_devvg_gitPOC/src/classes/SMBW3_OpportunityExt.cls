global class SMBW3_OpportunityExt {
    /*********************************Ankit Rustagi*********************************/
    public Attachment insertedAttach{get;set;}
    public Boolean sendForApproval{get;set;}
    public List<Attachment> attachments{get;set;}
    public List<AttachmentWrapper> attachmentWrapperList{get;set;}
    
    private final Opportunity oppt ;
    
    List<String> profileNameList = new List<String>
    {
        Profiles__c.getValues('Regional_Administrator_User_SAMBA').Id__c,Profiles__c.getValues('Sales_Operation_User_SAMBA').Id__c,Profiles__c.getValues('System_Administrator').Id__c
      //  System.Label.Regional_Administrator_User_SAMBA_Id, System.Label.Sales_Operation_SAMBA_Id, System.Label.System_Administrator_Id
    };
    
    public List<Note> getNotes(){
        return [SELECT Id, Title, LastModifiedDate, CreatedById FROM Note WHERE 
                ParentId =: ApexPages.currentPage().getParameters().get('id') ORDER BY LastModifiedDate DESC];
    }
    
    public SMBW3_OpportunityExt(ApexPages.StandardController controller) {
        if(!Test.isRunningTest())
        controller.addFields(new List<String>{'GAM_type__c'});
        this.oppt = (Opportunity)controller.getRecord();
        attachmentWrapperList = new List<AttachmentWrapper>();
        
        Map<Id, Attachment> mapAttachIdAndAttach = new Map<Id, Attachment>();
        
        for(Attachment a : [SELECT Id, Name, LastModifiedDate, CreatedById FROM Attachment WHERE ParentId =: ApexPages.currentPage().getParameters().get('id') 
                            AND CreatedBy.Profile.id IN : profileNameList])
        {
            mapAttachIdAndAttach.put(a.Id, a);
        }
        system.debug('profileNameList'+profileNameList);
        system.debug('mapAttachIdAndAttach'+mapAttachIdAndAttach);
        Set<Id> attachAssocToMastApprov = new Set<Id>();
        for(Master_Attachment_Approval__c maa : [SELECT Approve__c, Reject__c, Attachment_id__c FROM Master_Attachment_Approval__c 
                                                    WHERE Attachment_id__c IN : mapAttachIdAndAttach.keySet()])
        {
            if(maa.Approve__c)            
            attachmentWrapperList.add(new AttachmentWrapper(mapAttachIdAndAttach.get(maa.Attachment_id__c), true, maa.Id));
            else
            attachmentWrapperList.add(new AttachmentWrapper(mapAttachIdAndAttach.get(maa.Attachment_id__c), false, maa.Id));
            attachAssocToMastApprov.add(maa.Attachment_id__c);
        }
        attachmentWrapperList.sort();
        attachments = new List<Attachment>([SELECT Id, Name, LastModifiedDate, CreatedById FROM Attachment WHERE 
                ParentId =: ApexPages.currentPage().getParameters().get('id') AND Id NOT IN : attachAssocToMastApprov ORDER BY LastModifiedDate DESC]);
        

    }
    
    global class AttachmentWrapper implements Comparable{
        
        public Attachment attach{get;set;}
        public Boolean masterAttachApproveStatus{get;set;}
        public String masterAttachId{get;set;}
        
        public AttachmentWrapper(Attachment a, Boolean maas, String mai){
            attach = a;
            masterAttachApproveStatus = maas;
            masterAttachId = mai;
        }
        
        global Integer compareTo(Object compareTo) {
            AttachmentWrapper compareToAttachWrapp = (AttachmentWrapper)compareTo;
            if (attach.LastModifiedDate == compareToAttachWrapp.attach.LastModifiedDate) return 0;
            if (attach.LastModifiedDate < compareToAttachWrapp.attach.LastModifiedDate) return 1;
            return -1;       
        }
        
    }
    
    public String delId{get;set;}
    
    public void delAttachAndNote(){
        UserRecordAccess ura=[SELECT RecordId, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :delId];
        if (ura.HasDeleteAccess) {
            innerDelete.delId=delId;
            innerDelete.delAttachAndNote();
            //Database.delete(delId);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You do not have permission to delete this Record.'));
        }
    }
    
    InnerClassToDelete innerDelete=new InnerClassToDelete();
    
    public with sharing class InnerClassToDelete{
        public String delId{get;set;}

        public void delAttachAndNote(){
            try{
                Database.delete(delId);
            }catch(DmlException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDMLMessage(0)));
            }
        }
    }
    
    public PageReference navigateBack(){
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
    
    /*********************************End*********************************/

    String oppid{get;set;}
    
    
    Public Attachment myfile;
    Public Attachment getMyFile()
    {
        myfile = new Attachment();
        return myfile;
    }
   
   
    public static Boolean fromCode=false;
    Public Pagereference saveDoc()
    {
        oppid = System.currentPagereference().getParameters().get('id');
        Attachment a = new Attachment(parentId = oppid, name=myfile.name, body = myfile.body);
         
         /* insert the attachment */
        insert a;
        /*****************Modified By Ankit Rustagi*****************/
        insertedAttach = [SELECT Name, BodyLength FROM Attachment WHERE Id =: a.Id];        
        myfile.body=null;
        /*****************END*****************/        
        List<User> currUsrList=[select id, Profile.Name from User where id=:UserInfo.getUserId() AND Profile.Id IN : profileNameList];
        system.debug('llllll'+currUsrList);
        
        if ( !currUsrList.isEmpty() && oppt.GAM_type__c == 'Standard GAM' && sendForApproval) {
        try {
            fromCode=true;
            List<User> usrList=SMBW3_EmailToOppTeamMembers.retrieveUsers(new Set<Id>{oppid});
            
            List<Attachment_Approval__c> aaToInsert=new List<Attachment_Approval__c>();
            List<Role_Attachment_Approval__c> raToInsert=new List<Role_Attachment_Approval__c>();
            //List<Master_Attachment_Approval__c> maaToInsert=new List<Master_Attachment_Approval__c>();
            
            Map<User, Attachment_Approval__c> usrIdAA=new Map<User, Attachment_Approval__c>(); //<User, Attachment_Approval__c>
            Map<id, Role_Attachment_Approval__c> roleIdRA=new Map<id, Role_Attachment_Approval__c>(); //<RoleId, Role_Attachment_Approval__c>
            //NOT USED as only 1 MA will be there: Map<id, Master_Attachment_Approval__c> RAIdMA=new Map<id, Master_Attachment_Approval__c>(); //<Role_Attachment_Approval__c.id, Master_Attachment_Approval__c>
            
            
            Master_Attachment_Approval__c ma=new Master_Attachment_Approval__c(attachment_Id__c=a.id, name=a.name, Opportunity__c=oppid);
            //maaToInsert.add(ma);
            //insert maaToInsert;
            insert ma;

            //Prepare Role_Attachment_Approval__c from Master_Attachment_Approval__c
            for(User usr: usrList){
                
                if (usr.UserRole.developerName!=Label.SMBW3_CL037_InternationalRole && usr.UserRole.developerName!=Label.SMBW3_CL038_OBSGlobalRole){
                    Role_Attachment_Approval__c ra;
                    if ( !roleIdRA.keySet().contains(usr.UserRole.id) ) {
                        ra=new Role_Attachment_Approval__c(Master_Attachment_Approval__c=ma.id, RoleId__c=usr.UserRole.id, name=usr.UserRole.name);
                        roleIdRA.put(usr.UserRole.id, ra);
                        raToInsert.add(ra);
                    }
                }
            }
            
            insert raToInsert;

            for(User usr: usrList){
                if (usr.UserRole.developerName!=Label.SMBW3_CL037_InternationalRole && usr.UserRole.developerName!=Label.SMBW3_CL038_OBSGlobalRole){
                        Role_Attachment_Approval__c ra=roleIdRA.get(usr.UserRole.id);

                        Attachment_Approval__c aa=new Attachment_Approval__c(Approver__c=usr.id, Role_Attachment_Approval__c=ra.id, name=usr.name); //, Attachment_Id__c=a.id (Formula Field Now)
                        usrIdAA.put(usr, aa);
                        aaToInsert.add(aa);
                }
            }


            insert aaToInsert;
            
            //Send Emails
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            Integer emailSendLimit = Integer.valueOf(Label.SMB_CL029_EmailSendLimit);
            List<EmailTemplate> eTemplateList = [Select Id, Name from EmailTemplate where Name IN ('Opportunity Attachment Approval Mail','Opp OBSINT Approval Mail')];
            EmailTemplate eTemplateAA;
            EmailTemplate eTemplateMA;
            
            for (EmailTemplate et:eTemplateList){
                if (et.name=='Opportunity Attachment Approval Mail') {
                    eTemplateAA=et;
                } else {
                    eTemplateMA=et;
                }
            }
            
            Integer emailCount=0;
            //Latest Fix: for ( User usr: usrIdAA.keySet() ) {
          for ( User usr: usrList ) {
                
                
            String[] toAddresses = new String[] {}; 
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if (usr.UserRole.developerName!=Label.SMBW3_CL037_InternationalRole && usr.UserRole.developerName!=Label.SMBW3_CL038_OBSGlobalRole){
              mail.setWhatId( usrIdAA.get(usr).id );
              mail.setTargetObjectId(usr.id);
              mail.setTemplateId(eTemplateAA.id);
              mail.setSaveAsActivity(false);
              mailList.add(mail);
            } else {
              mail.setWhatId( ma.id );
              mail.setTargetObjectId(usr.id);
              mail.setTemplateId(eTemplateMA.id);
              mail.setSaveAsActivity(false);
              mailList.add(mail);
            }
            
              if (++emailCount>emailSendLimit){
                         Messaging.sendEmail(mailList);
                         mailList.clear();
                         emailCount=0;
               }
          }
        //}
        
            if ( !(emailCount>emailSendLimit) && emailCount!=0 ){
                             Messaging.sendEmail(mailList);
                             mailList.clear();
                             emailCount=0;
            }
         } finally {
            fromCode=false;
         }
        }
        /*****************Modified By Ankit Rustagi*****************/
        return ApexPages.currentPage();
        //return new PageReference('/'+oppid);
        /*****************End*****************/        
    }   

}