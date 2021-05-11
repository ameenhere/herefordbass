package here.ameen.hb.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProLeagueStyleStat implements Comparable<ProLeagueStyleStat>
{
    private static final double OPENING_KILL_COEFFICIENT = 0.031;
    private static final double OPENING_DEATH_COEFFICIENT = -0.042;
    private static final double KPR_COEFFICIENT = 0.666;
    private static final double SRV_COEFFICIENT = 0.261;
    private static final double KOST_COEFFICIENT = 0.225;
    private static final double ONE_V_X_COEFFICIENT = 0.066;
    private static final double PLANT_COEFFICIENT = 0.076;
    private static final double DEFUSE_COEFFICIENT = 0.033;
	
	private String player;
    private long kills;
    private long deaths;
    private long openingKills;
    private long openingDeaths;
    private long headshots;
    private double headshotPercentage;
    private long roundsPlayed;
    private long roundsSurvived;
    private long roundsWithKost;
    private double kost;
    private double srv;
    private double kpr;
    private double kd;
    private long plants;
    private long defuses;
    private long oneVxs;
    private double rating;
    
    @Override     
    public int compareTo(ProLeagueStyleStat candidate) {          
      return (this.getRating() < candidate.getRating() ? 1 : 
              (this.getRating() == candidate.getRating() ? 0 : -1));     
    }  
    
    public void populateCalculatedStats()
    {
		if (roundsPlayed > 0) {
			kost = ((double) roundsWithKost / (double) roundsPlayed);
			srv = ((double) roundsSurvived / (double) roundsPlayed);
		}
		kpr = (double) kills / (double) roundsPlayed;
		kd = (double) kills / (double) deaths;
		double unroundedRating = ((double)openingKills * OPENING_KILL_COEFFICIENT) + ((double)openingDeaths * OPENING_DEATH_COEFFICIENT) 
				+ ((double)kpr * KPR_COEFFICIENT) + ((double)srv * SRV_COEFFICIENT)
				+((double)kost * KOST_COEFFICIENT) + ((double)oneVxs * ONE_V_X_COEFFICIENT)
				+((double)plants * PLANT_COEFFICIENT) + ((double)defuses * DEFUSE_COEFFICIENT);
		
		BigDecimal bd = new BigDecimal(Double.toString(unroundedRating));
		bd = bd.setScale(2, RoundingMode.HALF_UP);
		rating = bd.doubleValue();
    }
    
	public String getKDWithDifference() {
		StringBuilder sb = new StringBuilder();
		sb.append(kills).append("-").append(deaths).append("(");
		if (kills > deaths) {
			sb.append("+").append(kills - deaths);
		} else if (kills == deaths) {
			sb.append(0);
		} else {
			sb.append("-").append(deaths - kills);
		}
		sb.append(")");
		return sb.toString();
	}
	
	public String getOpeningKillsAndDeathsWithDifference() {
		StringBuilder sb = new StringBuilder();
		sb.append(openingKills).append("-").append(openingDeaths).append("(");
		if (openingKills > openingDeaths) {
			sb.append("+").append(openingKills - openingDeaths);
		} else if (openingKills == openingDeaths) {
			sb.append(0);
		} else {
			sb.append("-").append(openingDeaths - openingKills);
		}
		sb.append(")");
		return sb.toString();
	}
	
	public long getKostPercentage() {
		return (long) Math.round(kost * 100);
	}
	
	public String getSrvPercentage() {
		return ((int) Math.round(srv * 100)) + "%";
	}
	
	public String getHsPercentage() {
		return ((int) Math.round(headshotPercentage)) + "%";
	}
	
	public double getRoundedKpr() {
		BigDecimal bd = new BigDecimal(Double.toString(kpr));
		bd = bd.setScale(2, RoundingMode.HALF_UP);
		return bd.doubleValue();
	}
	
}
