//[Jan 2015] UST-01269/WIT-002168: Handler class for Trigger to update access on Contacts through Criteria Based Sharing Rules if User Role is changed
public class updateAccessOnContactsOnUserHandler{

    //Future method to avoid error MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): Contact, original object: User
    @future
    public static void updateContacts(List<Id> usrIds){
            List<Contact> toUpdateAccessContacts=[select id, ownerId from Contact where ownerId IN :usrIds];
            if (!toUpdateAccessContacts.isEmpty()){
                update toUpdateAccessContacts;
            }
    }
    
}