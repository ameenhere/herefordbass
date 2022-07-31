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
@RequestMapping(value = "/charts", method = RequestMethod.GET)
@Slf4j
public class GoogleChartsController {

  @Autowired
  private StatsService statsService;

  @GetMapping("/")
  public String getPieChart(Model model) {
    Map<String, Integer> graphData = new LinkedHashMap<>();
    graphData.put("2016", 147);
    graphData.put("2017", 1256);
    graphData.put("2018", 3856);
    graphData.put("2019", 19807);
    model.addAttribute("chartData", graphData);
    model.addAttribute("title", "Sample Stats title");
    return "google-charts";
  }

  @GetMapping("/kd")
  public String getKdChart(@RequestParam(required = false, value = "season") Integer season,
      @RequestParam(required = false, value = "top") Integer top, Model model) {
    List<KD> kds = null;
    if (season == null || season < 1) {
      kds = statsService.getTotalKd();
    } else {
      kds = statsService.getKdForSeason(season);
    }

    if (top == null || top < 1) {
      top = 10;
    }

    Map<String, Double> graphData = new LinkedHashMap<>();
    Map<String, Double[]> tableData = new LinkedHashMap<>();
    for (int i = 0; i < top && i < kds.size(); i++) {
      graphData.put(kds.get(i).getName(), kds.get(i).getKd());
      tableData.put(kds.get(i).getName(), new Double[] {(double) kds.get(i).getKills(),
          (double) kds.get(i).getDeaths(), kds.get(i).getKd()});
    }

    model.addAttribute("chartData", graphData);
    model.addAttribute("tableData", tableData);

    Map<String, String> chartOpt = new HashMap<>();
    chartOpt.put("title", "Top K/D");
    chartOpt.put("htitle", "Player");
    chartOpt.put("vtitle", "K/D");

    model.addAttribute("chartOpt", chartOpt);
    model.addAttribute("title", "Top " + top + " K/D");
    return "stats-charts";
  }

  @GetMapping("/full")
  public String getFullChart(@RequestParam(value = "season") Integer season, Model model) {
    List<ProLeagueStyleStat> plStats = statsService.getProleagueStatsForSeason(season);

    Map<String, Object[]> tableData = new LinkedHashMap<>();
    for (int i = 0; i < plStats.size(); i++) {
      tableData.put(plStats.get(i).getPlayer(),
          new Object[] {(double) plStats.get(i).getRating(),
              (String) plStats.get(i).getKDWithDifference(),
              (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
              (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
              (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
              (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
    }
    model.addAttribute("tableData", tableData);

    return "pro-league";
  }

  @GetMapping("/season1")
  public String getTeamChart(Model model) {
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
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (redPlayers.contains(plStats.get(i).getPlayer())) {
        team2.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (orangePlayers.contains(plStats.get(i).getPlayer())) {
        team3.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (greenPlayers.contains(plStats.get(i).getPlayer())) {
        team4.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      } else
        log.warn("Unidentified Player:" + plStats.get(i).getPlayer());
    }
    model.addAttribute("team1", team1);
    model.addAttribute("team2", team2);
    model.addAttribute("team3", team3);
    model.addAttribute("team4", team4);

    return "season1";
  }


  @GetMapping("/season2")
  public String getTeamChart2(Model model) {
    List<ProLeagueStyleStat> plStats = statsService.getProleagueStatsForSeason(2);

    Set<String> targetBanned = new HashSet<>();
    targetBanned.add("Stan");
    targetBanned.add("Marras");
    targetBanned.add("CalLycus");
    targetBanned.add("RooClarke");
    targetBanned.add("Nex_Ingeniarius");
    targetBanned.add("Poseidon");
    targetBanned.add("senhasen");
    targetBanned.add("Omega");

    Set<String> justiceLeague = new HashSet<>();
    justiceLeague.add("Justice");
    justiceLeague.add("ameenHere");
    justiceLeague.add("FadeToBlue");
    justiceLeague.add("WishMaster");
    justiceLeague.add("Pacmyn");
    justiceLeague.add("polarctic");

    Set<String> spaghetti = new HashSet<>();
    spaghetti.add("Street");
    spaghetti.add("Scarecrow");
    spaghetti.add("Bauer");
    spaghetti.add("Jimmy");
    spaghetti.add("FrenchFrie");
    spaghetti.add("TheRandomGuy");
    spaghetti.add("fury");

    Set<String> magpies = new HashSet<>();
    magpies.add("Spade");
    magpies.add("GetMoisty");
    magpies.add("SaiyanbornQueen");
    magpies.add("Barboryx");
    magpies.add("Mastermagpie");
    magpies.add("MoodyCereal");
    magpies.add("speedymax");
    magpies.add("Tommy");

    Set<String> nasty = new HashSet<>();
    nasty.add("NastyHobbit");
    nasty.add("HotKebab");
    nasty.add("egons.on");
    nasty.add("TwinkPeach");
    nasty.add("Nathan492");
    nasty.add("Balf");
    nasty.add("OnThinIce");
    nasty.add("Vance");
    nasty.add("crimsonfever");
    nasty.add("Dante");

    Map<String, Object[]> team1 = new LinkedHashMap<>();
    Map<String, Object[]> team2 = new LinkedHashMap<>();
    Map<String, Object[]> team3 = new LinkedHashMap<>();
    Map<String, Object[]> team4 = new LinkedHashMap<>();
    Map<String, Object[]> team5 = new LinkedHashMap<>();
    for (int i = 0; i < plStats.size(); i++) {
      if (targetBanned.contains(plStats.get(i).getPlayer())) {
        team1.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (justiceLeague.contains(plStats.get(i).getPlayer())) {
        team2.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (spaghetti.contains(plStats.get(i).getPlayer())) {
        team3.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (magpies.contains(plStats.get(i).getPlayer())) {
        team4.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      else if (nasty.contains(plStats.get(i).getPlayer())) {
        team5.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      } else
        log.warn("Unidentified Player:" + plStats.get(i).getPlayer());
    }
    model.addAttribute("team1", team1);
    model.addAttribute("team2", team2);
    model.addAttribute("team3", team3);
    model.addAttribute("team4", team4);
    model.addAttribute("team5", team5);

    return "season2";
  }

  @GetMapping("/season3")
  public String getTeamChart3(Model model) {
    List<ProLeagueStyleStat> plStats = statsService.getProleagueStatsForSeason(3);

    Set<String> baguetteBandits = new HashSet<>();
    baguetteBandits.add("Stan");
    baguetteBandits.add("Pac");
    baguetteBandits.add("Nex");
    baguetteBandits.add("FrenchFrie");
    baguetteBandits.add("Cowboy");
    baguetteBandits.add("Scarecrow");
    baguetteBandits.add("Jimmy");
    baguetteBandits.add("Blue");

    Set<String> theDarkHorse = new HashSet<>();
    theDarkHorse.add("Justice");
    theDarkHorse.add("ameenHere");
    theDarkHorse.add("Wish");
    theDarkHorse.add("Anszi");
    theDarkHorse.add("Balf");
    theDarkHorse.add("DiddlyLauren");
    theDarkHorse.add("Rain");
    theDarkHorse.add("SaltiAlpaca");
    theDarkHorse.add("NastyHobbit");
    theDarkHorse.add("Dante");

    Set<String> omegaminds = new HashSet<>();
    omegaminds.add("Weseley");
    omegaminds.add("Street");
    omegaminds.add("Panick");
    omegaminds.add("Omega");
    omegaminds.add("Moisty");
    omegaminds.add("Fin");
    omegaminds.add("Roo");
    omegaminds.add("Liam");
    omegaminds.add("Cal");

    Set<String> joshsEmpire = new HashSet<>();
    joshsEmpire.add("Corpse");
    joshsEmpire.add("Street");
    joshsEmpire.add("Josh");
    joshsEmpire.add("Wes");
    joshsEmpire.add("Magpie");
    joshsEmpire.add("Aehab");
    joshsEmpire.add("Speedy");
    joshsEmpire.add("Jackie");


    Map<String, Object[]> team1 = new LinkedHashMap<>();
    Map<String, Object[]> team2 = new LinkedHashMap<>();
    Map<String, Object[]> team3 = new LinkedHashMap<>();
    Map<String, Object[]> team4 = new LinkedHashMap<>();

    for (int i = 0; i < plStats.size(); i++) {
      boolean playerTaken = false;
      if (omegaminds.contains(plStats.get(i).getPlayer())) {
        playerTaken = true;
        team1.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      if (baguetteBandits.contains(plStats.get(i).getPlayer())) {
        playerTaken = true;
        team2.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      if (joshsEmpire.contains(plStats.get(i).getPlayer())) {
        playerTaken = true;
        team3.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }

      if (theDarkHorse.contains(plStats.get(i).getPlayer())) {
        playerTaken = true;
        team4.put(plStats.get(i).getPlayer(),
            new Object[] {(double) plStats.get(i).getRating(),
                (String) plStats.get(i).getKDWithDifference(),
                (String) plStats.get(i).getOpeningKillsAndDeathsWithDifference(),
                (double) plStats.get(i).getKost(), (double) plStats.get(i).getRoundedKpr(),
                (String) plStats.get(i).getSrvPercentage(), (int) plStats.get(i).getOneVxs(),
                (int) plStats.get(i).getPlants(), (String) plStats.get(i).getHsPercentage()});
      }


      if (!playerTaken) {
        log.warn("Unidentified Player:" + plStats.get(i).getPlayer());
      }
    }
    model.addAttribute("team1", team1);
    model.addAttribute("team2", team2);
    model.addAttribute("team3", team3);
    model.addAttribute("team4", team4);

    return "season3";
  }

}
