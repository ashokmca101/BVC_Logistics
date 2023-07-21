trigger ContentDistributionTrigger on ContentDistribution (after insert) 
{
    System.debug(' inside ContentDistribution trigger');
	for(ContentDistribution cd : trigger.new)
    {
        System.debug('Id :'+cd.Id);
        System.debug('ContentDownloadUrl :'+cd.ContentDownloadUrl);
        System.debug('DistributionPublicUrl :'+cd.DistributionPublicUrl);
    }
}