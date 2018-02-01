package xmladaptertest;

import static org.junit.Assert.fail;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.nio.charset.Charset;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;

import org.fabianlee.xmladaptertest.domain.AddressBook;
import org.fabianlee.xmladaptertest.domain.AddressEntry;
import org.junit.Test;

public class TestReadXML {
	
	// classpath location to sample address book XML
	private String ADDRESS_XML = "/addressbook1.xml";

	
	@Test
	public void testAddressBook() throws Exception {

		// get XML from classpath
		InputStream is = getClass().getResourceAsStream(ADDRESS_XML);

		// allows XML to not have to specify charset 
		Charset inputCharset = Charset.forName("UTF-8");
		InputStreamReader isreader = new InputStreamReader(is,inputCharset);
		
        AddressBook addressBook = null;
        try {
        	// unmarshall XML into domain graph
            JAXBContext jaxbContext = JAXBContext.newInstance(AddressBook.class);
            Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
            addressBook = (AddressBook) jaxbUnmarshaller.unmarshal(is);

            // show using toString()
    		System.out.println("--TOSTRING----------");
    		System.out.println(addressBook.toString());
            System.out.println();
            
            // show using marshalled XML
    		System.out.println("--XML----------");
    		String xmlStr = getXMLAsString(addressBook);
    		System.out.println(xmlStr);
            System.out.println();

    		// show as HTML
    		System.out.println("--HTML----------");
            String htmlStr = getAddressBookAsHTML(addressBook);
            System.out.println(htmlStr);
            System.out.println();
            
    		// write HTML to file that can be viewed in browser
            File htmlFile = new File("addressbook.html");
    		FileWriter fw = new FileWriter(htmlFile);
    		fw.write(htmlStr);
    		fw.close();
    		System.out.println("Use browser to open file: " + htmlFile.getAbsolutePath());
            
        }catch(JAXBException e) {
            e.printStackTrace();
        	fail(e.getMessage());
        }
		
	}
	

	// create XML representation of domain object graph
	private String getXMLAsString(Object object) throws Exception {
		
		StringWriter sw = new StringWriter();
		JAXBContext context = JAXBContext.newInstance(object.getClass());
		Marshaller m = context.createMarshaller();
		
		//for pretty-print XML in JAXB
		m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
		m.setProperty(Marshaller.JAXB_FRAGMENT, Boolean.TRUE);

		// Write to File
		m.marshal(object, sw);
		return sw.toString();
	}
	
	// create HTML rendition of domain object graph
	private String getAddressBookAsHTML(AddressBook addressBook) throws Exception {
		StringWriter sw = new StringWriter();
		sw.append("<html><head/><body>").append(System.lineSeparator());
		
		sw.append("<h1>Address Book</h1>").append(System.lineSeparator());
		sw.append("<table width=\"400\" border=\"1\">").append(System.lineSeparator());
		for(AddressEntry entry:addressBook.getEntries()) {
			sw.append("<tr>");
			sw.append("<td>").append(entry.getName()).append("</td>");
			sw.append("<td>").append(entry.getGender().toString()).append("</td>");
			if(entry.getAvatar()!=null) {
				
				// write PNG avatar image to disk
				FileOutputStream fos = new FileOutputStream(entry.getName() + ".png");
				fos.write(entry.getAvatar().getImage());
				fos.close();

				// create img src for HTML
				sw.append("<td>").append("<img src=\"").append(entry.getName() + ".png").append("\"/>").append("</td>");
			}else {
				sw.append("<td>&nbsp;</td>");
			}
			sw.append("</tr>").append(System.lineSeparator());
			
		}
		sw.append("</table>").append(System.lineSeparator());
		
		sw.append("</body></html>");
		
		return sw.toString();
	}

}
