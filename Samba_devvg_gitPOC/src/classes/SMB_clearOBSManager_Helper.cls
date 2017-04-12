public class SMB_clearOBSManager_Helper{

@future
public static void sendEmails(Map<String, String> regionEmail, Map<String, String> regionContentMap, Map<String, String> regionOBSManager){
    List<Messaging.SingleEmailMessage> toSend=new List<Messaging.SingleEmailMessage>();
    For (String region: regionContentMap.keySet()){
                    Messaging.SingleEmailMessage sem=new Messaging.SingleEmailMessage();
                    sem.setSubject('Some OBS Managers got deactivated');
                    sem.setToAddresses(regionEmail.get(region).split(','));
                    sem.setPlainTextBody(regionContentMap.get(region) +
                    '\nPlease assign another OBS Manager(s) to the above user(s) .\n \n Many Thanks');
                    toSend.add(sem);
    }
    
    Messaging.sendEmail(toSend);
    
}

}