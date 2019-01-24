# States and Types


Making network calls can be expensive and slow, especially if the device has little connectivity. Being aware of the network connection state can prevent your app from attempting to make network calls when the network isn't available.

Sometimes it's also important for your app to know what kind of connectivity the device has: Wi-Fi networks are typically faster than data networks, and data networks are often metered and expensive. To control when certain tasks are performed, monitor the network state and respond appropriately. For example, you may want to wait until the device is connected to Wifi to perform a large file download.



To check the network connection, use the following classes:

ConnectivityManager answers queries about the state of network connectivity. It also notifies apps when network connectivity changes.
NetworkInfo describes the status of a network interface of a given type (currently either mobile or Wi-Fi).


The following code snippet tests whether Wi-Fi and mobile are connected. In the code:

- The getSystemService() method gets an instance of ConnectivityManager from the context.
- The getNetworkInfo() method gets the status of the device's Wi-Fi connection, then its mobile connection. The getNetworkInfo() method returns a NetworkInfo object, which contains information about the given network's connection status (whether that connection is idle, connecting, and so on).
- The networkInfo.isConnected() method returns true if the given network is connected. If the network is connected, it can be used to establish sockets and pass data.

```java
private static final String DEBUG_TAG = "NetworkStatusExample";
ConnectivityManager connMgr = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
NetworkInfo networkInfo = connMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
boolean isWifiConn = networkInfo.isConnected();
networkInfo = connMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
boolean isMobileConn = networkInfo.isConnected();
Log.d(DEBUG_TAG, "Wifi connected: " + isWifiConn);
Log.d(DEBUG_TAG, "Mobile connected: " + isMobileConn);
```

```java
ConnectivityManager connMgr = (ConnectivityManager)
           getSystemService(Context.CONNECTIVITY_SERVICE);
NetworkInfo networkInfo = null;
if (connMgr != null) {
   networkInfo = connMgr.getActiveNetworkInfo();
}

if (networkInfo != null && networkInfo.isConnected()
           && queryString.length() != 0) {
   // do something
}
```
