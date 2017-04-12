public class PMT_KanbanBoardController {
    public Map<String, List <user_Story__c>> CompleteBacklog {get; set;}
    public String request {get; set;}

	private List<String> StatusBacklog;
    private List<String> StatusInProgress;
    private List<String> StatusTest;
    private List<String> StatusDone;
    private List<String> FOTeamDone;

    private String QueryBacklog;
    
    public PMT_KanbanBoardController() {
        // Criteria for the Boards
        StatusBacklog = new List<String> {'\'3. Approved\'' }; 
        StatusInProgress = new List<String> {'\'4. In progress\'', '\'5. Ready for build\'', '\'6. Building\''};
        StatusTest = new List<String> {'\'7. Built\''};
        StatusDone = new List<String> {'\'8. Done\''};
        FOTeamDone = new List<String> {'EZIN', 'KILA', 'VALLAT', 'SERRAT'};

        if (CompleteBacklog == null) CompleteBacklog = new Map<String, List <user_Story__c>>();

        // First part of the request
		QueryBacklog = 'SELECT Id, ';
        QueryBacklog += 'Name, ';
        QueryBacklog += 'User_Story_Title__c, ';
        QueryBacklog += 'Requirement_Description__c, ';
        QueryBacklog += 'PMT_UST_Lead_Solution_Stream_FO__c, ';
		QueryBacklog += 'User_Story_Status__c, ';
        QueryBacklog += 'PMT_UST_Lead_Solution_Stream_FO__r.FullPhotoUrl, ';
        QueryBacklog += 'PMT_UST_Lead_Change__r.FirstName, ';
        QueryBacklog += 'PMT_UST_Lead_Change__r.LastName, ';
        QueryBacklog += 'PMT_UST_Lead_CoE_Build_BO__r.FirstName, ';
        QueryBacklog += 'PMT_UST_Lead_CoE_Build_BO__r.LastName, ';
        QueryBacklog += 'PMT_UST_Agile_Build_Delivery_Date__c, ';
        QueryBacklog += 'PMT_UST_Lead_Solution_Stream_FO__r.FirstName, ';
        QueryBacklog += 'PMT_UST_Lead_Solution_Stream_FO__r.LastName ';
        QueryBacklog += 'FROM user_Story__c ';
        
        refreshKanban();
    }
    
    public void refreshKanban() {
        // Filter Status
        List<String> FilterStatus = new List<String>{};
		FilterStatus.add('(User_Story_Status__c IN ('+ String.join(StatusBacklog, ',') +'))');
        FilterStatus.add('(User_Story_Status__c IN ('+ String.join(StatusInProgress, ',') +'))');
        FilterStatus.add('(User_Story_Status__c IN ('+ String.join(StatusTest, ',') +'))');
        FilterStatus.add('(User_Story_Status__c IN ('+ String.join(StatusDone, ',') +'))');

        // Filter FO
        String FilterFo = 'AND PMT_UST_Lead_Solution_Stream_FO__r.Lastname ';
	
        // Convert List to Set to access contains method (fugly)
	    Set<String> setBacklog = new Set<String>(StatusBacklog);
        Set<String> setInProgress = new Set<String>(StatusInProgress);
        Set<String> setToTest = new Set<String>(StatusTest);
        Set<String> setDone = new Set<String>(StatusDone);

        request = QueryBacklog + ' WHERE ' + String.join(FilterStatus,  'OR');
        List <user_Story__c> temp_list = new List<user_Story__c>();
        CompleteBacklog.put('1. Backlog', new List<user_Story__c>());
        CompleteBacklog.put('2. In progress', new List<user_Story__c>());
        CompleteBacklog.put('3. To be tested', new List<user_Story__c>());
        CompleteBacklog.put('4. Done', new List<user_Story__c>());
        
        
        for (user_Story__c onestory : Database.query(request)) {
            if (setBacklog.contains('\''+onestory.User_Story_Status__c+'\''))
                if (CompleteBacklog.containsKey('1. Backlog'))
                CompleteBacklog.get('1. Backlog').add(onestory);
            
            if (setInProgress.contains('\''+onestory.User_Story_Status__c+'\''))
                if (CompleteBacklog.containsKey('2. In progress'))
                CompleteBacklog.get('2. In progress').add(onestory);
            
            if (setToTest.contains('\''+onestory.User_Story_Status__c+'\''))
                if (CompleteBacklog.containsKey('3. To be tested'))
                CompleteBacklog.get('3. To be tested').add(onestory);
            
            if (setDone.contains('\''+onestory.User_Story_Status__c+'\''))
                if (CompleteBacklog.containsKey('4. Done'))
                CompleteBacklog.get('4. Done').add(onestory);
        }
        
        
    }
}