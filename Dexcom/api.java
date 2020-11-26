public class api{
    public static void main(String[] args) {
        //First refresh the Bearer token. Pull the refresh token stored in s3 after each function call.
        
        OkHttpClient client = new OkHttpClient();
        Request request = new Request.Builder()
        .url("https://api.dexcom.com/v2/users/self/egvs?startDate=2017-06-16T15:30:00&endDate=2017-06-16T15:45:00")
        .get()
        .addHeader("authorization", "Bearer {your_access_token}")
        .build();

        Response response = client.newCall(request).execute();
    }
}