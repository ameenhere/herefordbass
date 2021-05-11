package here.ameen.hb.controllers;

import java.util.Collection;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import here.ameen.hb.model.Headshot;
import here.ameen.hb.model.KD;
import here.ameen.hb.model.Nemesis;
import here.ameen.hb.model.ProLeagueStyleStat;
import here.ameen.hb.services.StatsService;

@RestController
@RequestMapping( value = "/stats", method = RequestMethod.GET )
public class StatsController
{

    @Autowired
    private StatsService statsService;

    @RequestMapping( value = "/kd", method = RequestMethod.GET )
    public List<KD> getAllPlayersKd( @RequestParam( required = false, value = "season" ) Integer season )
    {
        if ( season == null || season < 1 )
        {
            return statsService.getTotalKd();
        }
        return statsService.getKdForSeason( season );
    }

    @RequestMapping( value = "/nemesis", method = RequestMethod.GET )
    public List<Nemesis> getAllPlayersNemesis( @RequestParam( required = false, value = "season" ) Integer season )
    {
        if ( season == null || season < 1 )
        {
            return statsService.getTotalNemesis();
        }
        return statsService.getNemesisForSeason( season );
    }

    @RequestMapping( value = "/hs", method = RequestMethod.GET )
    public List<Headshot> getAllPlayersHeadshots( @RequestParam( required = false, value = "season" ) Integer season )
    {
        if ( season == null || season < 1 )
        {
            return statsService.getTotalHeadshot();
        }
        return statsService.getHeadshotForSeason( season );
    }
    
    @RequestMapping( value = "/hsp", method = RequestMethod.GET )
    public List<Headshot> getAllPlayersHeadshotPercentage( @RequestParam( required = false, value = "season" ) Integer season )
    {
        if ( season == null || season < 1 )
        {
            return statsService.getTotalHeadshotPercentage();
        }
        return statsService.getHeadshotPercentageForSeason( season );
    }
    
    
    @RequestMapping( value = "/proleague", method = RequestMethod.GET )
    public Collection<ProLeagueStyleStat> getProleagueStats( @RequestParam( required = false, value = "season" ) Integer season )
    {
    	 if ( season == null || season < 1 )
         {
             return statsService.getTotalProleagueStats();
         }
         return statsService.getProleagueStatsForSeason( season );
    }
}
