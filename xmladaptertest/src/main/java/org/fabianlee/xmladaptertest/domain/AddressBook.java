package org.fabianlee.xmladaptertest.domain;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlRootElement(name = "addressbook")
public class AddressBook {

	@XmlElementWrapper(name = "entries")
	@XmlElement(name = "entry")
	protected List<AddressEntry> entries = new ArrayList<AddressEntry>();
	
	
	
	public List<AddressEntry> getEntries() {
		return entries;
	}
	public void setEntries(List<AddressEntry> entries) {
		this.entries = entries;
	}


	@Override
	public String toString() {
		StringBuffer sb = new StringBuffer("Address book:").append(System.lineSeparator());
		// show each entry
		for(AddressEntry entry:entries) {
			sb.append("\t" + entry.toString() + System.lineSeparator());
		}
		return sb.toString();
	}


}
