package resource;

import java.util.List;

import obj.SERVICES;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import dao.ServiceDbDao;

@RestController
@RequestMapping("/javaDayTokyo")
public class JavaDayTokyoController {

	static ServiceDbDao serDbDao = new ServiceDbDao();

	@RequestMapping(value = "/list", method = RequestMethod.GET)
	public String getList() throws JSONException {
		// Get ALL Data
		List<SERVICES> sList = serDbDao.getAllServices();
		JSONArray jArray = new JSONArray();
		setJsonArray(sList, jArray);
		return jArray.toString();
	}

	@RequestMapping(value = "/list/{type}", method = RequestMethod.GET)
	public String showListbyType(@PathVariable("type") String type)
			throws JSONException {
		// Get Data By Type
		List<SERVICES> sList = serDbDao.getByType(type);
		JSONArray jArray = new JSONArray();
		setJsonArray(sList, jArray);
		return jArray.toString();
	}

	@RequestMapping(value = "/service/{name}", method = RequestMethod.GET)
	public String searchByName(@PathVariable("name") String name)
			throws JSONException {
		// Get Data By Name
		List<SERVICES> sList = serDbDao.getByName(name);
		JSONArray jArray = new JSONArray();
		setJsonArray(sList, jArray);
		return jArray.toString();
	}

	private void setJsonArray(List<SERVICES> sList, JSONArray jArray) {
		//Set JsonArray
		for (SERVICES ser : sList) {
			JSONObject jo = new JSONObject();
			try {
				jo.put("name", ser.getNAME());
				jo.put("type", ser.getTYPE());
				jo.put("price", ser.getPRICE());
				jo.put("metric", ser.getMETRIC());
				jo.put("description", ser.getDESCRIPTION());
				jo.put("link", ser.getLINK());
				jArray.put(jo);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	/* Just4test */
	
	 /* public static void main(String[] args) throws JSONException {
	  JavaDayTokyoController jdtc = new JavaDayTokyoController();
	  System.out.println(jdtc.searchByName("cloud")); }*/
	 
}