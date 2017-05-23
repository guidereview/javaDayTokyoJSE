package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;



import obj.DBConnection;
import obj.SERVICES;

public class ServiceDbDao implements IServicesDao {

	private Connection conn = null;
	
	private static final String SQL_GET_ALL_SERVICES = "select * from SERVICES";
	private static final String SQL_GET_SERVICE_BYNAME = "select * from SERVICES WHERE NAME LIKE '%";
	private static final String SQL_GET_SERVICE_BYNAME_SUFFIX = "%'";
	private static final String SQL_GET_SERVICE_TYPE = "select * from SERVICES WHERE TYPE ='";
	private static final String SQL_GET_SERVICE_TYPE_SUFFIX = "'";

	@Override
	public List<SERVICES> getAllServices() {
		// Get ALL SERVICES List from DB
		String SQLQuery = SQL_GET_ALL_SERVICES;
		List<SERVICES> list = new ArrayList<SERVICES>();
		setServices(list,SQLQuery);
		return list;
	}

	@Override
	public List<SERVICES> getByName(String NAME) {
		// Get ALL SERVICES List By Name from DB
		String SQLQuery = SQL_GET_SERVICE_BYNAME + NAME + SQL_GET_SERVICE_BYNAME_SUFFIX;
		List<SERVICES> list = new ArrayList<SERVICES>();
		setServices(list,SQLQuery);
		return list;
	}

	@Override
	public List<SERVICES> getByType(String TYPE) {
		// Get ALL SERVICES List By Type from DB
		String SQLQuery = SQL_GET_SERVICE_TYPE + TYPE + SQL_GET_SERVICE_TYPE_SUFFIX;
		List<SERVICES> list = new ArrayList<SERVICES>();
		setServices(list,SQLQuery);
		return list;
	}

	private void setServices(List<SERVICES> list,String SQL){
		//Set the Objects from DB to the List
		conn = DBConnection.getInstance().getConnection();
		PreparedStatement pstmt = null;
		try {
			pstmt = conn.prepareStatement(SQL);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next()) {
				SERVICES services = new SERVICES();
				services.setNAME(rs.getString(1));
				services.setTYPE(rs.getString(2));
				services.setPRICE(rs.getDouble(3));
				services.setMETRIC(rs.getString(4));
				services.setDESCRIPTION(rs.getString(5));
				services.setLINK(rs.getString(6));
				list.add(services);
			}
			rs.close();
			DBConnection.getInstance().closeConnection();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/* Just4Test */
	/*public static void main(String[] args) {
		ServiceDbDao sDd = new ServiceDbDao();
		List<SERVICES> ser = sDd.getByType("iaas");
		System.out.println(ser.get(0).getNAME());
		System.out.println(ser.get(1).getNAME());
		System.out.println("============================");
	}*/
}
