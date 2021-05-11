package here.ameen.hb.controllers;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import here.ameen.hb.services.DataQualityService;

@RestController
@RequestMapping( value = "/quality", method = RequestMethod.GET )
public class DataQualityController
{
    
    @Autowired
    private DataQualityService dataQualityService;
    
    @RequestMapping( value = "/names", method = RequestMethod.GET )
    public List<String> fixPlayerNames( @RequestParam( required = false, value = "season" ) Integer season )
    {
        List<String[]> names = new ArrayList<>();
        names.add(new String[]{"Assassin1701", "Assassin"});
        names.add(new String[]{"AhmedAXDM", "Ahmed"});
        names.add(new String[]{"Lord_Cinnamon", "Cinnamon"});
        names.add(new String[]{"Copperhead923", "Copperhead"});
        names.add(new String[]{"DEEJAY", "Deejay"});
        names.add(new String[]{"eskimoking37", "Eski"});
        names.add(new String[]{"Llama_Animal", "llama_animal","Llama_animal"});
        names.add(new String[]{"JaMiEkIlLeR99", "JamieKiller"});
        names.add(new String[]{"Lollix7", "Lollix"});
        names.add(new String[]{"MajorDirt", "MajorDIrt"});
        names.add(new String[]{"Nex_Ingeniarius", "Nex"});
        names.add(new String[]{"LethalParrot","Parrot"});
        names.add(new String[]{"Next1-SaS","NextCF"});
       names.add(new String[]{"xReXRoYx","RexRoy"});
        names.add(new String[]{"Segments-SaS","Segments-Sas","priceyM9"});
        names.add(new String[]{"Sleepyguy0208","Sleepy"});
       names.add(new String[]{"Street","Streetrider"});
        names.add(new String[]{"Envy-PandaE","Somnambulent__","somnambulent__"});
        names.add(new String[]{"Squizzy","squizzy"});
        names.add(new String[]{"Caliph","SweetMemeCaliph","sweetMemeCaliph"});
//        names.add(new String[]{"TheDemonsHead135","thedemonshead135","TheDemonsHead"});
//        names.add(new String[]{"TommyKL","tommykl"});
//        names.add(new String[]{"Wesley_360_Snipz","wesley_360_Snipz"});
        names.add(new String[]{"XxRHYPERIORxX","XxRhyperiorxX"});
        names.add(new String[]{"Jayo_616","jm_616"});
//        names.add(new String[]{"Matex","matexkhan7"});
        
        return dataQualityService.fixIncorrectNames( names );
    }
}
