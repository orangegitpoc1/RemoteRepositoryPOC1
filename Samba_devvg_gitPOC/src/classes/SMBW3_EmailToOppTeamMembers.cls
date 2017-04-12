public class SMBW3_EmailToOppTeamMembers{
    
    static Map<Id, Id> mapRoleWiseParentRole = new Map<Id, Id>();
    
    static{
        for(UserRole ur : [SELECT Id, ParentRoleId FROM UserRole]){
            mapRoleWiseParentRole.put(ur.Id, ur.ParentRoleId);
        }
    }
    
    public static List<User> retrieveUsers(Set<Id> oppIds){
        Set<Id> setOfUserRoleIds = new Set<Id>();
        List<User> listOfEligibleUsers = new List<User>();
        
        for(OpportunityTeamMember opt : [SELECT Id, User.Profile.Name, User.UserRoleId FROM 
                                            OpportunityTeamMember WHERE OpportunityId IN : oppIds])
        {
            if(opt.User.Profile.Name == System.Label.Sales_User_SAMBA  || opt.User.Profile.Name==System.Label.Business_Developer_User_SAMBA){
                setOfUserRoleIds.add(opt.User.UserRoleId);
            }
        }
        
        for(Id roleId : setOfUserRoleIds){
            Id parentRoleId = roleId;
            while(parentRoleId!=null){
                parentRoleId = mapRoleWiseParentRole.get(parentRoleId);
                if(parentRoleId!=null)
                setOfUserRoleIds.add(parentRoleId);
            }
        }
        
        for(User u : [SELECT Id, Profile.Name, SMB_User_Notify__c, Frequency__c, Name, UserRole.name, UserRole.developerName FROM User WHERE 
                        UserRoleId IN : setOfUserRoleIds])
        {
            if(u.Profile.Name == System.Label.Sales_Operation_SAMBA){
                listOfEligibleUsers.add(u);
            }
            
            
        }
        return listOfEligibleUsers;
    }
    
    public static void sendEmail(Set<Id> oppIds, String body, String frequencyType){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        for(User u : retrieveUsers(oppIds))
        {
            if(u.SMB_User_Notify__c=true && u.Frequency__c == frequencyType)
            {
                mailList.add(SendingEmailHelper.processEmail
                (u.Id, 
                System.Label.SMBW3_CL0015_DigestMessage+' '+frequencyType, 
                System.Label.SMBW3_CL0016_Hello+' '+u.Name+',<br><br>'+body+'<br><br>'+
                System.Label.SMBW3_CL0017_SystemEmailMessage, null, null));
                /*
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(u.Id);            
                mail.setSubject(System.Label.SMBW3_CL0015_DigestMessage+' '+frequencyType);
                String bdy = System.Label.SMBW3_CL0016_Hello+' '+u.Name+',<br><br>'+body+'<br><br>'+System.Label.SMBW3_CL0017_SystemEmailMessage;            
                mail.setHtmlBody(bdy);
                mail.setSaveAsActivity(false);
                mailList.add(mail);
                */
            }
                         
        }
        Messaging.sendEmail(mailList);
    }

}