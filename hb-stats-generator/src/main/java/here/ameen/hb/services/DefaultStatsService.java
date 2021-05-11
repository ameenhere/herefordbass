package here.ameen.hb.services;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import here.ameen.hb.dao.StatsDao;
import here.ameen.hb.model.Headshot;
import here.ameen.hb.model.KD;
import here.ameen.hb.model.Nemesis;
import here.ameen.hb.model.ProLeagueStyleStat;
import here.ameen.hb.model.SingleValue;

@Service
public class DefaultStatsService
    implements
    StatsService
{

    @Autowired
    private StatsDao statsDao;

    @Override
    public List<KD> getKdForSeason( int season )
    {
        return statsDao.getKdForSeason( season );
    }

    @Override
    public List<KD> getTotalKd()
    {
        return statsDao.getTotalKd();
    }

    @Override
    public List<Nemesis> getNemesisForSeason( int season )
    {
        return statsDao.getNemesisForSeason( season );
    }

    @Override
    public List<Nemesis> getTotalNemesis()
    {
        return statsDao.getTotalNemesis();
    }

    @Override
    public List<Headshot> getHeadshotPercentageForSeason( int season )
    {
        return statsDao.getHeadshotPercentageForSeason( season );
    }

    @Override
    public List<Headshot> getTotalHeadshotPercentage()
    {
        return statsDao.getTotalHeadshotPercentage();
    }

	@Override
	public List<ProLeagueStyleStat> getTotalProleagueStats() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<ProLeagueStyleStat> getProleagueStatsForSeason(int season) {
		List<SingleValue> roundsPlayedList = statsDao.getSeasonalRoundsPlayed(season);
		List<KD> kdList = statsDao.getKdForSeason(season);
		List<Headshot> headshotList = statsDao.getHeadshotPercentageForSeason(season);
		List<SingleValue> roundsWithKostList = statsDao.getSeasonalKostRounds(season);
		List<SingleValue> roundsSurvivedList = statsDao.getSeasonalRoundsSurvived(season);
		List<SingleValue> roundsPlantedList = statsDao.getSeasonalRoundsPlanted(season);
		List<SingleValue> openingKillsList = statsDao.getSeasonalOpeningKills(season);
		List<SingleValue> openingDeathsList = statsDao.getSeasonalOpeningDeaths(season);
		List<SingleValue> oneVxClutchesList = statsDao.getSeasonalOneVxClutches(season);

		Map<String, ProLeagueStyleStat> plstatMap = new HashMap<>();

		ProLeagueStyleStat currentPlStat = null;
		for (KD kd : kdList) {
			currentPlStat = plstatMap.get(kd.getName());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setPlayer(kd.getName());
			currentPlStat.setKills(kd.getKills());
			currentPlStat.setDeaths(kd.getDeaths());
			plstatMap.put(kd.getName(), currentPlStat);
		}

		for (Headshot hs : headshotList) {
			currentPlStat = plstatMap.get(hs.getName());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setHeadshots(hs.getHeadshots());
			currentPlStat.setHeadshotPercentage(hs.getHeadshotPercentage());
			plstatMap.put(hs.getName(), currentPlStat);
		}

		for (SingleValue rp : roundsPlayedList) {
			currentPlStat = plstatMap.get(rp.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setRoundsPlayed(rp.getValue());
			plstatMap.put(rp.getPlayer(), currentPlStat);
		}

		for (SingleValue rs : roundsSurvivedList) {
			currentPlStat = plstatMap.get(rs.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setRoundsSurvived(rs.getValue());
			plstatMap.put(rs.getPlayer(), currentPlStat);
		}

		for (SingleValue rwk : roundsWithKostList) {
			currentPlStat = plstatMap.get(rwk.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setRoundsWithKost(rwk.getValue());
			plstatMap.put(rwk.getPlayer(), currentPlStat);
		}

		for (SingleValue rpl : roundsPlantedList) {
			currentPlStat = plstatMap.get(rpl.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setPlants(rpl.getValue());
			plstatMap.put(rpl.getPlayer(), currentPlStat);
		}

		for (SingleValue ok : openingKillsList) {
			currentPlStat = plstatMap.get(ok.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setOpeningKills(ok.getValue());
			plstatMap.put(ok.getPlayer(), currentPlStat);
		}

		for (SingleValue od : openingDeathsList) {
			currentPlStat = plstatMap.get(od.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setOpeningDeaths(od.getValue());
			plstatMap.put(od.getPlayer(), currentPlStat);
		}
		
		for (SingleValue ovx : oneVxClutchesList) {
			currentPlStat = plstatMap.get(ovx.getPlayer());
			if (currentPlStat == null) {
				currentPlStat = new ProLeagueStyleStat();
			}
			currentPlStat.setOneVxs(ovx.getValue());
			plstatMap.put(ovx.getPlayer(), currentPlStat);
		}

		List<ProLeagueStyleStat> plStats = plstatMap.values().stream().map(plStat -> {
			plStat.populateCalculatedStats();
			return plStat;
		}).collect(Collectors.toList());
		Collections.sort(plStats);
		return plStats;
	}

	@Override
	public List<Headshot> getHeadshotForSeason(int season) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Headshot> getTotalHeadshot() {
		// TODO Auto-generated method stub
		return null;
	}

}
