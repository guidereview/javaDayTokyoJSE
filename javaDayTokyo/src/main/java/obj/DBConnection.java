package obj;

import com.mysql.jdbc.Connection;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Optional;

public class DBConnection {
	
    private static final String DRIVER = "com.mysql.jdbc.Driver";
    //Environment Variable Cloud
    public static final Optional<String> MYSQLCS_USER_NAME = Optional.ofNullable(System.getenv("MYSQLCS_USER_NAME"));
    public static final Optional<String> MYSQLCS_USER_PASSWORD = Optional.ofNullable(System.getenv("MYSQLCS_USER_PASSWORD"));
    public static final Optional<String> MYSQLCS_CONNECT_STRING = Optional.ofNullable(System.getenv("MYSQLCS_CONNECT_STRING"));
    
    private static final String URL = "jdbc:mysql://";

    //Local settings        
    public static final String LOCAL_USERNAME = "root";
    public static final String LOCAL_PASSWORD = "1qaz!QAZ";
    public static final String LOCAL_DEFAULT_CONNECT_DESCRIPTOR = "localhost:13306/javadaytokyo";
	
	private static Connection connection = null;
    private static DBConnection instance = null;

    private DBConnection() {
        try {
            Class.forName(DRIVER).newInstance();
        } catch (Exception sqle) {
            sqle.getMessage();
            sqle.printStackTrace();
        }
    }

    public static DBConnection getInstance() {
        try {
			if (connection == null || connection.isClosed()) {
			    instance = new DBConnection();
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return instance;
    }
    
    public Connection getConnection() {
        try {
			if (connection == null || connection.isClosed()) {
			    try {			    	
			    	connection = (Connection) DriverManager.getConnection(
			    			URL + MYSQLCS_CONNECT_STRING.orElse(LOCAL_DEFAULT_CONNECT_DESCRIPTOR), 
			    			MYSQLCS_USER_NAME.orElse(LOCAL_USERNAME), 
			    			MYSQLCS_USER_PASSWORD.orElse(LOCAL_PASSWORD));
			    } catch (SQLException e) {
			        e.getMessage();
			        e.printStackTrace();
			    }
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return connection;
    }
    
    public void closeConnection(){
    	try{
    		if (connection != null && !connection.isClosed()) {
    			connection.close();
    			}
    		}
    	catch(SQLException e) {
            	e.getMessage();
            	e.printStackTrace();
    			} 
    		} 
    }
  /* Just4Test 
   * public static void main(String[] args) {
    	DBConnection dConn = new DBConnection();
    	dConn.getConnection();
	}*/
