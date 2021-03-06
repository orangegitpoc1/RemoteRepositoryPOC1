public class SMBW1_DataLoad_Sandbox {
/*
* Make sure your class is using the latest API version. Some features in this class
* will only work with API v19 or higher.
*/
 
	private final String RESOURCE_NAME = 'object_csv';
 
    private List<String> lines = new List<String>();
 
    // Map instead of list since I need the .remove() method AND
    // Map instead of set since DML can't be performed on set of SObject
    private Map<String, SObject> objsToInsert = new Map<String, SObject>();
 
    // A map to associate our external Ids as defined in the CSV with SObject Ids.
    // This helps the code associate related objects. Using two similar maps
    // since this one will hold ALL records (think reference-Map) but the one
    // above holds a running list of uncommited records (think action-Map)
    private Map<String, SObject> extIdMap = new Map<String, SObject>();
 
    public StaticResource theStaticResource{get;set;}
 
    public SMBW1_DataLoad_Sandbox(){
        fetchResource(RESOURCE_NAME);
    }
 
    public SMBW1_DataLoad_Sandbox(String resourceName){
        fetchResource(resourceName);
    }
 
    // Run over the lines in the files
    public List<SObject> parseCsv(){
        String bodyText = theStaticResource.body.toString();
 
        // Break the body into it's constituent lines
        List<String> bodyLines = bodyText.split('\n');
 
        for(String line: bodyLines){
            // Ignore comment and empty lines
            if(line.trim().length() == 0){
                continue;
            }
            System.debug('Key-value pair: '+line);
 
            SObject s = munch(line);
 
        }
 
        List<SObject> objs = objsToInsert.values();
 
        return objs;
    }
 
    // Robotic muncher. Eats CSV lines and returns
    // SObjects.
    private SObject munch(String s){
        SObject obj;
 
        // Rearrange the CSV line into a list of string values
        List<String> keyValuePairs = s.split(',');
 
        String eId;
 
        for(String pairString: keyValuePairs){
            // Some boilerplate splitting
            List<String> pairs = pairString.split(':');
 
            String key = pairs[0].trim(); // Don't forget to Trim!
            String value = pairs[1].trim(); // Waste not, want not.
 
            // Reserved keyword in the CSV markup - used
            // to denote the object name
            if(key == 'object'){
                obj = createSObject(value);
            // Reserved keyword - denotes the parent record Id
            } else if(key == 'relatedTo'){
 
                // More boilerplate
                List<String> referenceFields = value.split('#');
                String fieldName = referenceFields[0];
                String extId = referenceFields[1];
 
                // Find the parent record. Now here we violate the
                // 'No DML in a loop' golden rule because the parent
                // record Id is required for the association. There is
                // way to get around this by using a few lists and a map
                // or two. I don't deem it necessary since I have direct
                // control over the number of records in the sample file
                SObject parentObj = extIdMap.get(extId);
                if(parentObj.id == null){
                    insert parentObj;
                    objsToInsert.remove(extId);
                }
 
                obj.put(fieldName, parentObj.id);
            // Reserved keyword - used to associate my CSV record
            // Id and the salesforce record Id
            } else if( key == 'extId' ){
                eId = value;
            // Everything else i.e. the real field values
            } else {
                obj.put(key, value);
            }
 
        }
 
        objsToInsert.put(eId, obj);
        extIdMap.put(eId, obj);
 
        return obj;
    }
 
    // Helper that instantiates a generic SObject
    private SObject createSObject(String objectName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        SObject s = t.newSObject();
        return s;
    }
 
    private void fetchResource(String resourceName){
        try{
 
            theStaticResource = [SELECT id, Body FROM StaticResource WHERE name = :resourceName];
 
        }catch(System.QueryException e){
            System.debug(e);
            // You should always let the admins/devs know if
            // something unexpected happened.
            // e.g. ExceptionUtils.mail(Administrator);
        }
    }
}