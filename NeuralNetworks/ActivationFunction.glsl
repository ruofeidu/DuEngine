/** 
 * Visualization of various activation functions by Ruofei Du (DuRuofei.com)
 * LeRU, tanh, sigmoid, ELU, atan, softplus
 * The receptive field varies with different activation functions. 
 *
 * RF_{l+1} = RF_i + (kernel_size_{l+1} - 1) \times feature_stride_i
 * e.g., 1, (1+(3-1)*1)=3, 3+(3-1)*1 = 5
 * 
 * The effect receptive field is smaller, and we should enrich receptive fields and discretize anchors over layers
 * 
 * Reference: 
 * [1] Understanding the Effective Receptive Field in Deep Convolutional Neural Networks. https://arxiv.org/abs/1701.04128
 * [2] https://towardsdatascience.com/activation-functions-neural-networks-1cbd9f8d91d6
 * Link to ShaderToy demo: https://www.shadertoy.com/view/4lccRB
 **/

// The Sigmoid Function curve looks like a S-shape, a.k.a., Logistic Activation Function
// The main reason why we use sigmoid function is because it exists between (0 to 1). 
// Therefore, it is especially used for models where we have to predict the probability as an output.
// Since probability of anything exists only between the range of 0 and 1, sigmoid is the right choice.
// The function is differentiable.That means, we can find the slope of the sigmoid curve at any two points.
// The function is monotonic but function’s derivative is not.
// The logistic sigmoid function can cause a neural network to get stuck at the training time.
// The softmax function is a more generalized logistic activation function which is used for multiclass classification.
float sigmoid(float a, float f) {
	return 1.0 / (1.0 + exp(-f * a));
}

// The ReLU is the most used activation function in the world right now.
// Rectified Linear Unit
// Since, it is used in almost all the convolutional neural networks or deep learning.
// The function and its derivative both are monotonic.
// But the issue is that all the negative values become zero immediately which decreases 
// the ability of the model to fit or train from the data properly.
// That means any negative input given to the ReLU activation function turns the value into zero immediately in the graph, 
// which in turns affects the resulting graph by not mapping the negative values appropriately.

float ReLU(float x) {
    return max(0.0, x);
}


// Leaky ReLU, a.k.a., Parameteric Rectified Linear Unit
// The leak helps to increase the range of the ReLU function. Usually, the value of a is 0.01 or so.
// When a is not 0.01 then it is called Randomized ReLU.
// Therefore the range of the Leaky ReLU is (-infinity to infinity).
// Both Leaky and Randomized ReLU functions are monotonic in nature. Also, their derivatives also monotonic in nature.
float leakyReLU(float x) {
    const float a = 0.01;
    return step(x, 0.0) * a * x + step(0.0, x) * x; 
}

// Exponential Linear Unit (ELU)
float ELU(float x) {
    const float a = 0.01;
    return step(x, 0.0) * a * (exp(x) - 1.0) + step(0.0, x) * x;
}

// The softmax function is a more generalized logistic activation function which is used for multiclass classification.
float softplus(float x) {
    return log(1.0 + exp(x));
}

float TanH(float x) {
	return 2.0 / (1.0 + exp(-2.0 * x)) - 1.0;    
}

float CHAR(vec2 p, int C) {
    if (p.x < 0. || p.x > 1. || p.y < 0.|| p.y > 1.) return 0.;
    return textureGrad(iChannel0, p/16. + fract(vec2(C, 15-C/16) / 16.), dFdx(p/16.),dFdy(p/16.) ).r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ap = max(iResolution.x, iResolution.y) / min(iResolution.x, iResolution.y);
    vec2 p = fragCoord / iResolution.xy;
    vec2 uv = (fragCoord + fragCoord - iResolution.xy) / iResolution.y;
    
    vec3 col;
    
    if (p.x > 2.0 / 3.0) {
        uv.y += 0.5 * step(p.y, 0.5) - 0.5 * step(0.5, p.y);
        uv.x = uv.x + 1.0 * ap - 5.0 / 6.0 * 2.0 * ap;
        uv *= 3.0;
        
        if (p.y > 0.5) {
            col = vec3(1.0-sigmoid(length(uv), 1.0));
        } else {
            col = vec3(1.0-softplus(length(uv)));
        }
    } 
    else if (p.x > 1.0 / 3.0) {
        uv.y += 0.5 * step(p.y, 0.5) - 0.5 * step(0.5, p.y);
        uv *= 3.0;
        if (p.y > 0.5) {
            // tanh is also like logistic sigmoid but better. 
            // The range of the tanh function is from (-1 to 1). tanh is also sigmoidal (s - shaped).
            // The advantage is that the negative inputs will be mapped strongly negative and 
            // the zero inputs will be mapped near zero in the tanh graph.
            // The function is differentiable. The function is monotonic while its derivative is not monotonic.
            // The tanh function is mainly used classification between two classes.
            // Both tanh and logistic sigmoid activation functions are used in feed-forward nets.
            col = vec3(1.0-tanh(length(uv)));
        } else {
        	col = vec3(1.0-atan(length(uv)));
        }
    } else {
        uv.y += 0.5 * step(p.y, 0.5) - 0.5 * step(0.5, p.y);
        uv.x = uv.x + 1.0 * ap - 1.0 / 6.0 * 2.0 * ap;
        uv *= 3.0;
        if (p.y > 0.5) {
            col = vec3(1.0-ReLU(length(uv)));
        } else {
            col = vec3(1.0-ELU(length(uv)));
        }
    }
	
    vec3 fontColor = vec3(1.0); 
    p *= ap;
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(0.,   9.3), 76));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(.5,   9.3), 69));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(1.,   9.3), 82));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(1.5,  9.3), 85));
    
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(6.,   9.3), 84));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(6.5,  9.3), 65));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(7.,   9.3), 78));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(7.5,  9.3), 72));
    
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(12.,  9.3), 83));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(12.5, 9.3), 73));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(13.,  9.3), 71));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(13.5, 9.3), 77));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(14.,  9.3), 79));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(14.5, 9.3), 73));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(15.,  9.3), 68));
    
    
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(0.,   0.3), 69));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(0.5,   0.3), 76));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(1.0,  0.3), 85));
    
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(6.,   0.3), 65));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(6.5,  0.3), 84));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(7.,   0.3), 65));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(7.5,  0.3), 78));
    
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(12.,  0.3), 83));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(12.5, 0.3), 79));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(13.,  0.3), 70));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(13.5, 0.3), 84));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(14.,  0.3), 80));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(14.5, 0.3), 76));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(15.,  0.3), 85));
    col = mix(col, fontColor, CHAR((p * 10.0) - vec2(15.5, 0.3), 83));
	
    fragColor = vec4(col,1.0);
}
