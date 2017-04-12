public Class SMB_AccountTriggerhandler{
 
    public  void beforeinsert(Map<id,Account>NewMapAccount,Map<id,Account>OldMapAccount,list<Account> NewAccount,list<Account> OldAccount){
        //Automatic marketing manager bases on owners cluster
        //UST-1270
        SMB_AccountManagerMapping SLMM=new SMB_AccountManagerMapping ();
        SLMM.insertMarketingManager(NewAccount);
        //end UST 1270
    }
    
    public  void beforeUpdate(Map<id,Account>NewMapAccount,Map<id,Account>OldMapAccount,list<account> NewAccount,list<Account> OldAccount){
       //Automatic marketing manager bases on owners cluster
       //UST-1270
       SMB_AccountManagerMapping SLMM=new SMB_AccountManagerMapping ();
       SLMM.UpdateMarketingManager(NewMapAccount,OldMapAccount,NewAccount,OldAccount);
       
       //end UST 1270 
    }
    public void AfterUpdate(Map<id,Account>NewMapAccount,Map<id,Account>OldMapAccount,list<account> NewAccount,list<Account> OldAccount){
      //UST-1270 update contacts marketing manager email text and name text
       SMB_AccountManagerMapping SLMM=new SMB_AccountManagerMapping ();
       SLMM.UpdateContactMarketingEmail_Name_Text(NewMapAccount,OldMapAccount,NewAccount,OldAccount);
    //end of ust 1270
    }
}