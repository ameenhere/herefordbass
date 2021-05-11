package here.ameen.hb.services;

import java.util.List;

import here.ameen.hb.model.Headshot;
import here.ameen.hb.model.KD;
import here.ameen.hb.model.Nemesis;
import here.ameen.hb.model.ProLeagueStyleStat;

public interface StatsService
{
    List<KD> getKdForSeason( int season );

    List<KD> getTotalKd();
    
    List<Nemesis> getNemesisForSeason( int season );

    List<Nemesis> getTotalNemesis();

    List<Headshot> getHeadshotPercentageForSeason( int season );

    List<Headshot> getTotalHeadshotPercentage();

    List<Headshot> getHeadshotForSeason( int season );

    List<Headshot> getTotalHeadshot();

	List<ProLeagueStyleStat> getTotalProleagueStats();

	List<ProLeagueStyleStat> getProleagueStatsForSeason(int season);
}
