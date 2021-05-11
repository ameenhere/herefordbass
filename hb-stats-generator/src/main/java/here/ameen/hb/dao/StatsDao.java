package here.ameen.hb.dao;

import java.util.List;

import here.ameen.hb.model.Headshot;
import here.ameen.hb.model.KD;
import here.ameen.hb.model.Nemesis;
import here.ameen.hb.model.SingleValue;

public interface StatsDao {
	List<KD> getKdForSeason(int season);

	List<KD> getTotalKd();

	List<Nemesis> getNemesisForSeason(int season);

	List<Nemesis> getTotalNemesis();

	List<Headshot> getHeadshotPercentageForSeason(int season);

	List<Headshot> getTotalHeadshotPercentage();

	List<SingleValue> getSeasonalRoundsPlayed(int season);

	List<SingleValue> getTotalRoundsPlayed();

	List<SingleValue> getSeasonalKostRounds(int season);

	List<SingleValue> getTotalKostRounds();
	
	List<SingleValue> getSeasonalRoundsPlanted(int season);

	List<SingleValue> getTotalRoundsPlanted();
	
	List<SingleValue> getSeasonalRoundsSurvived(int season);

	List<SingleValue> getTotalRoundsSurvived();

	List<SingleValue> getSeasonalOpeningKills(int season);

	List<SingleValue> getTotalOpeningKills();

	List<SingleValue> getTotalOpeningDeaths();

	List<SingleValue> getSeasonalOpeningDeaths(int season);

	List<SingleValue> getTotalRoundsDefused();

	List<SingleValue> getSeasonalRoundsDefused(int season);

	List<SingleValue> getSeasonalOneVxClutches(int season);

	List<SingleValue> getTotalOneVxClutches();
}
