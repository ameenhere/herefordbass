package here.ameen.hb.controllers;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import here.ameen.hb.model.KD;
import here.ameen.hb.model.ProLeagueStyleStat;
import here.ameen.hb.services.StatsService;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequestMapping( value = "/charts", method = RequestMethod.GET )
@Slf4j
public class GoogleChartsController
{

    @Autowired
    private StatsService statsService;

    @GetMapping( "/" )
    public String getPieChart( Model model )
    {
        Map<String, Integer> graphData = new LinkedHashMap<>();
        graphData.put( "2016", 147 );
        graphData.put( "2017", 1256 );
        graphData.put( "2018", 3856 );
        graphData.put( "2019", 19807 );
        model.addAttribute( "chartData", graphData );
        model.addAttribute( "title", "Sample Stats title" );
        return "google-charts";
    }

    @GetMapping( "/kd" )
    public String getKdChart( @RequestParam( required = false, value = "season" ) Integer season,
        @RequestParam( required = false, value = "top" ) Integer top, Model model )
    {
        List<KD> kds = null;
        if ( season == null || season < 1 )
        {
            kds = statsService.getTotalKd();
        }
        else
        {
            kds = statsService.getKdForSeason( season );
        }

        if ( top == null || top < 1 )
        {
            top = 10;
        }

        Map<String, Double> graphData = new LinkedHashMap<>();
        Map<String, Double[]> tableData = new LinkedHashMap<>();
        for ( int i = 0; i < top && i < kds.size(); i++ )
        {
            graphData.put( kds.get( i ).getName(), kds.get( i ).getKd() );
            tableData.put( kds.get( i ).getName(), new Double[] {(double) kds.get( i ).getKills(),(double) kds.get( i ).getDeaths(),kds.get( i ).getKd()} );
        }

        model.addAttribute( "chartData", graphData );
        model.addAttribute( "tableData", tableData );
        
        Map<String, String> chartOpt = new HashMap<>();
        chartOpt.put( "title", "Top K/D" );
        chartOpt.put( "htitle", "Player" );
        chartOpt.put( "vtitle", "K/D" );
        
        model.addAttribute( "chartOpt", chartOpt );
        model.addAttribute( "title", "Top " + top + " K/D" );
        return "stats-charts";
    }
    
    @GetMapping( "/full" )
    public String getFullChart( @RequestParam(value = "season" ) Integer season, Model model )
	{
		List<ProLeagueStyleStat> plStats = statsService.getProleagueStatsForSeason(season);

		Map<String, Object[]> tableData = new LinkedHashMap<>();
		for (int i = 0; i < plStats.size(); i++) {
			tableData.put(plStats.get(i).getPlayer(),
					new Object[] { (double) plStats.get(i).getRating(),
							(String) plStats.get(i).getKDWithDifference(),
							(String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
							(double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
							(String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
							(int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage() });
		}
		model.addAttribute("tableData", tableData);

		return "pro-league";
	}
    
    @GetMapping( "/season1" )
    public String getTeamChart( Model model )
	{
		List<ProLeagueStyleStat> plStats = statsService.getProleagueStatsForSeason(1);

		Set<String> bluePlayers = new HashSet<>();
		bluePlayers.add("HotKebab");
		bluePlayers.add("Next");
		bluePlayers.add("SaiyanbornQueen");
		bluePlayers.add("Street");
		bluePlayers.add("MrLiam");
		bluePlayers.add("NastyHobbit");
		bluePlayers.add("FadeToBlue");

		Set<String> redPlayers = new HashSet<>();
		redPlayers.add("Stan");
		redPlayers.add("Wes");
		redPlayers.add("FrenchFrie");
		redPlayers.add("Jimmy");
		redPlayers.add("Nex_Ingeniarius");
		redPlayers.add("Omega");
		redPlayers.add("egons.on");

		Set<String> orangePlayers = new HashSet<>();
		orangePlayers.add("ameenHere");
		orangePlayers.add("MoodyCereal");
		orangePlayers.add("Bauer");
		orangePlayers.add("speedymax");
		orangePlayers.add("lxrde");
		orangePlayers.add("OnThinIce");

		Set<String> greenPlayers = new HashSet<>();
		greenPlayers.add("HaiDing");
		greenPlayers.add("Marras");
		greenPlayers.add("Scarecrow");
		greenPlayers.add("Justice");
		greenPlayers.add("Mastermagpie");
		greenPlayers.add("CalLycus");
		greenPlayers.add("crimsonfever");

		Map<String, Object[]> team1 = new LinkedHashMap<>();
		Map<String, Object[]> team2 = new LinkedHashMap<>();
		Map<String, Object[]> team3 = new LinkedHashMap<>();
		Map<String, Object[]> team4 = new LinkedHashMap<>();
		for (int i = 0; i < plStats.size(); i++) {
			if (bluePlayers.contains(plStats.get(i).getPlayer())) {
				team1.put(plStats.get(i).getPlayer(),
						new Object[] { (double) plStats.get(i).getRating(),
								(String) plStats.get(i).getKDWithDifference(),
								(String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
								(double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
								(String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
								(int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage() });
			}

			else if (redPlayers.contains(plStats.get(i).getPlayer())) {
				team2.put(plStats.get(i).getPlayer(),
						new Object[] { (double) plStats.get(i).getRating(),
								(String) plStats.get(i).getKDWithDifference(),
								(String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
								(double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
								(String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
								(int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage() });
			}

			else if (orangePlayers.contains(plStats.get(i).getPlayer())) {
				team3.put(plStats.get(i).getPlayer(),
						new Object[] { (double) plStats.get(i).getRating(),
								(String) plStats.get(i).getKDWithDifference(),
								(String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
								(double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
								(String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
								(int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage() });
			}

			else if (greenPlayers.contains(plStats.get(i).getPlayer())) {
				team4.put(plStats.get(i).getPlayer(),
						new Object[] { (double) plStats.get(i).getRating(),
								(String) plStats.get(i).getKDWithDifference(),
								(String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
								(double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
								(String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
								(int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage() });
			}
			else log.warn("Unidentified Player:" + plStats.get(i).getPlayer());
		}
		model.addAttribute("team1", team1);
		model.addAttribute("team2", team2);
		model.addAttribute("team3", team3);
		model.addAttribute("team4", team4);

		return "season1";
	}
    
}