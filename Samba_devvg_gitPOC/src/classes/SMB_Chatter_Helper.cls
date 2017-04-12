public class SMB_Chatter_Helper {

    public static ConnectApi.BatchInput createFeedList(Id recordId, Id userId, String message){
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = recordId;
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        if(userId!=null){
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = userId;
            body.messageSegments.add(mentionSegmentInput);
        }
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = message;    
        body.messageSegments.add(textSegment);
        
        input.body = body;
        
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
        return batchInput;
        //batchInputs.add(batchInput);
    }
    
    public static void postBulkChatterFeed(List<ConnectApi.BatchInput> batchInputs){
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
    }

}