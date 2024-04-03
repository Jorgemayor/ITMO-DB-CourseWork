import axios from "axios";

const API_URL = 'http://localhost:3001';

const config = {
    baseURL: API_URL,
    // withCredentials: true,
    headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
    },
};

const axiosInstance = axios.create(config);

export const get = (url, options) =>
    axiosInstance
        .get(url, options)
        .then((res) => res.data)
        .catch((error) => {
            throw error.response?.data ?? error;
        });

export const post = (
    url,
    body,
    options
) =>
    axiosInstance
        .post(url, body, options)
        .then((res) => res.data)
        .catch((error) => {
            throw error.response?.data ?? error;
        });

// const onFullfilledAuthTokenInterceptor = async (
//     requestConfig,
// ) => {
//     const authTokens = getAuthTokens();
//     if (authTokens.accessToken) {
//         requestConfig.headers = requestConfig.headers ?? {};
//         requestConfig.headers.Authorization = `JWT ${authTokens.accessToken}`;
//     }
//     return requestConfig;
// };
//
// axiosInstance.interceptors.request.use(onFullfilledAuthTokenInterceptor);
