import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:social_app/modules/login/login_cubit/cubit.dart';
import 'package:social_app/modules/login/login_cubit/states.dart';
import 'package:social_app/modules/register/register_screen.dart';
import 'package:social_app/shared/components/components.dart';
import 'package:toast/toast.dart';
import '../../cubit/cubit.dart';
import '../../layout/social_layout.dart';
import '../../shared/network/local/cache_helper.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  var formKey = GlobalKey <FormState> ();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    ToastContext().init(context);
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(),
      child: BlocConsumer <LoginCubit, LoginStates>(
        listener: (context, state)
        {
          if (state is LoginErrorState)
            {
              Toast.show(state.error, backgroundColor: Colors.red, gravity: Toast.bottom);
            }
            if (state is LoginSuccessState)
            {

                CacheHelper.saveData(key: 'uId', value: state.uId).then((value)
                {
                  navigateAndFinish(context, const SocialLayout());
                });
                Toast.show('Login Done Successfully', duration: Toast.lengthLong, gravity:  Toast.bottom, backgroundColor: Colors.green);
              }
        },
        builder:(context, state) => Scaffold(
          backgroundColor: SocialCubit.get(context).isDark ? HexColor('333739') : Colors.white,
          appBar: AppBar(),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text(
                        'LOGIN',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Login now to communicate with friends',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SocialCubit.get(context).isDark ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      defaultFormField(
                        context,
                        controller: emailController,
                        type: TextInputType.emailAddress,
                        validate: (String? value)
                        {
                          if (value!.isEmpty)
                          {
                            return 'Please, Enter your Email Address';
                          }
                          return null;
                        },
                        labelText: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(
                        height: 17.0,
                      ),
                      defaultFormField(
                        context,
                        controller: passwordController,
                        type: TextInputType.visiblePassword,
                        suffixIcon: LoginCubit.get(context).suffix,
                        onFieldSubmitted: (value)
                        {
                          if (formKey.currentState!.validate())
                          {
                            LoginCubit.get(context).userLogin(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          }
                        },
                        isPassword: LoginCubit.get(context).isPasswordShown,
                        suffixPressed: ()
                        {
                          LoginCubit.get(context).changePasswordVisibility();
                        },
                        validate: (value)
                        {
                          if (value!.isEmpty)
                          {
                            return 'Password should not be Empty';
                          }
                          return null;
                        },
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ConditionalBuilder(
                        condition: state is! LoginLoadingState,
                        builder: (context) => defaultButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              LoginCubit.get(context).userLogin(
                                  email: emailController.text,
                                  password: passwordController.text,
                              );
                            }
                          },
                          text: 'login',
                          isUpperCase: true,
                        ),
                        fallback: (context) => const Center(child: CircularProgressIndicator()),
                      ),
                      const SizedBox(
                        height: 17.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children:
                          [
                            Text(
                              'Don\'t have an Account?',
                              style: TextStyle(
                                color: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            defaultTextButton(
                              onPressed: ()
                              {
                                navigateTo(context, RegisterScreen());
                              },
                              text: 'register',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
