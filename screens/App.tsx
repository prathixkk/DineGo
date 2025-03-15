import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoginPage from './LoginPage';
import RegisterPage from './RegisterPage';
import ScanQr from './ScanQr';

type RootStackParamList = {
  Login: undefined;
  Register: undefined;
};

export default function App() {

  const NStack = createNativeStackNavigator();
  return (
    <NavigationContainer>
      <NStack.Navigator initialRouteName="Scanner" screenOptions={{ headerShown: false }}>
      <NStack.Screen name="Scanner" component={ScanQr} />
        <NStack.Screen name="Login" component={LoginPage} />
        <NStack.Screen name="Register" component={RegisterPage} />
      </NStack.Navigator>
    </NavigationContainer>
  );
}
