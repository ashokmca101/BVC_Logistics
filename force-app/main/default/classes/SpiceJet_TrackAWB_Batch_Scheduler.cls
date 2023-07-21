global class SpiceJet_TrackAWB_Batch_Scheduler {
global void execute(SchedulableContext sc) { 
     // this scheduler is used to schedule SpiceJet_TrackAWB_Batch , number of batches is 10
        SpiceJet_TrackAWB_Batch lineTracking = new SpiceJet_TrackAWB_Batch();
        database.executebatch(lineTracking,10);
    }
}