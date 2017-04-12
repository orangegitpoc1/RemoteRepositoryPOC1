public Class SMB_LeadTriggerhandler{
 
    public  void beforeinsert(Map<id,lead>NewMaplead,Map<id,lead>OldMaplead,list<lead> Newlead,list<lead> Oldlead){
        //Ust-1270 Lead manager automatic using define list in custom setting 
        SMB_LeadManagerMapping SLMM=new SMB_LeadManagerMapping();
        SLMM.insertMarketingManager(Newlead);
    }
    
    public  void beforeUpdate(Map<id,lead>NewMaplead,Map<id,lead>OldMaplead,list<lead> Newlead,list<lead> Oldlead){
       //Ust-1270 Lead manager automatic using define list in custom setting 
       SMB_LeadManagerMapping SLMM=new SMB_LeadManagerMapping();
       SLMM.UpdateMarketingManager(NewMaplead,OldMaplead,Newlead,Oldlead);
    }
}