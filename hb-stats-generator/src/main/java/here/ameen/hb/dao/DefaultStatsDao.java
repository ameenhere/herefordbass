package here.ameen.hb.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import here.ameen.hb.model.Headshot;
import here.ameen.hb.model.KD;
import here.ameen.hb.model.Nemesis;
import here.ameen.hb.model.SingleValue;

@Repository
public class DefaultStatsDao implements StatsDao {

	@Value("${seasonKd}")
	private String seasonKd;

	@Value("${totalKd}")
	private String totalKdQuery;

	@Value("${seasonNemesis}")
	private String seasonNemesis;

	@Value("${totalNemesis}")
	private String totalNemesis;

	@Value("${seasonHeadshotPercentage}")
	private String seasonHeadshotPercentage;

	@Value("${totalHeadshotPercentage}")
	private String totalHeadshotPercentage;

	@Value("${seasonRoundsPlayed}")
	private String seasonRoundsPlayed;

	@Value("${totalRoundsPlayed}")
	private String totalRoundsPlayed;

	@Value("${seasonRoundsSurvived}")
	private String seasonRoundsSurvived;

	@Value("${totalRoundsSurvived}")
	private String totalRoundsSurvived;

	@Value("${seasonRoundsPlanted}")
	private String seasonRoundsPlanted;

	@Value("${totalRoundsPlanted}")
	private String totalRoundsPlanted;
	
	@Value("${seasonRoundsDefused}")
	private String seasonRoundsDefused;

	@Value("${totalRoundsDefused}")
	private String totalRoundsDefused;

	@Value("${seasonKostRounds}")
	private String seasonKostRounds;

	@Value("${totalKostRounds}")
	private String totalKostRounds;

	@Value("${tradeWindowSeconds}")
	private int tradeWindowSeconds;
	
	@Value("${seasonOpeningKills}")
	private String seasonOpeningKills;
	
	@Value("${totalOpeningKills}")
	private String totalOpeningKills;
	
	@Value("${seasonOpeningDeaths}")
	private String seasonOpeningDeaths;
	
	@Value("${totalOpeningDeaths}")
	private String totalOpeningDeaths;
	
	@Value("${seasonOneVxClutches}")
	private String seasonOneVxClutches;
	
	@Value("${totalOneVxClutches}")
	private String totalOneVxClutches;

	@Autowired
	private NamedParameterJdbcTemplate jdbcTemplate;

	@Override
	public List<KD> getKdForSeason(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonKd, paramMap, new KDRowMapper());
	}

	@Override
	public List<KD> getTotalKd() {
		return jdbcTemplate.query(totalKdQuery, new KDRowMapper());
	}

	@Override
	public List<Nemesis> getNemesisForSeason(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonNemesis, paramMap, new NemesisRowMapper());
	}

	@Override
	public List<Nemesis> getTotalNemesis() {
		return jdbcTemplate.query(totalNemesis, new NemesisRowMapper());
	}

	@Override
	public List<Headshot> getHeadshotPercentageForSeason(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonHeadshotPercentage, paramMap, new HeadshotPercentageRowMapper());
	}

	@Override
	public List<Headshot> getTotalHeadshotPercentage() {
		return jdbcTemplate.query(totalHeadshotPercentage, new HeadshotPercentageRowMapper());
	}

	@Override
	public List<SingleValue> getSeasonalRoundsPlayed(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonRoundsPlayed, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalRoundsPlayed() {
		return jdbcTemplate.query(totalRoundsPlayed, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalRoundsSurvived() {
		return jdbcTemplate.query(totalRoundsSurvived, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getSeasonalRoundsSurvived(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonRoundsSurvived, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalRoundsPlanted() {
		return jdbcTemplate.query(totalRoundsPlanted, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getSeasonalRoundsDefused(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonRoundsDefused, paramMap, new SingleValueRowMapper());
	}
	
	@Override
	public List<SingleValue> getTotalRoundsDefused() {
		return jdbcTemplate.query(totalRoundsDefused, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getSeasonalRoundsPlanted(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonRoundsPlanted, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getSeasonalKostRounds(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		paramMap.put("tradeWindowSeconds", tradeWindowSeconds);
		return jdbcTemplate.query(seasonKostRounds, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalKostRounds() {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("tradeWindowSeconds", tradeWindowSeconds);
		return jdbcTemplate.query(totalKostRounds, paramMap, new SingleValueRowMapper());
	}
	
	@Override
	public List<SingleValue> getSeasonalOpeningKills(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonOpeningKills, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalOpeningKills() {
		return jdbcTemplate.query(totalOpeningKills, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getSeasonalOpeningDeaths(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonOpeningDeaths, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalOpeningDeaths() {
		return jdbcTemplate.query(totalOpeningDeaths, new SingleValueRowMapper());
	}
	
	@Override
	public List<SingleValue> getSeasonalOneVxClutches(int season) {
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("season", season);
		return jdbcTemplate.query(seasonOneVxClutches, paramMap, new SingleValueRowMapper());
	}

	@Override
	public List<SingleValue> getTotalOneVxClutches() {
		return jdbcTemplate.query(totalOneVxClutches, new SingleValueRowMapper());
	}
}
