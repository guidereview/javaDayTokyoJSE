package dao;

import java.util.List;

import obj.SERVICES;

public interface IServicesDao {
	public List<SERVICES> getAllServices();
    public List<SERVICES> getByName(String NAME);
    public List<SERVICES> getByType(String Type);
}
